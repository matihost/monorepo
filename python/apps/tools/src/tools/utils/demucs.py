"""Demucs based audio source separation.

Demucs pulls in PyTorch with CUDA libraries (several GB), which is too heavy to be
a regular dependency of this project. Instead it is installed on demand into a
dedicated virtual env outside of this project and reused on subsequent runs.
"""

import os
import subprocess
import venv
from pathlib import Path

from tools.utils.system import run_streamed

DEFAULT_VENV = Path.home() / ".venv" / "demucs"

# stems of htdemucs_6s, the only bundled Demucs model with a separate guitar stem
SIX_STEMS = ("drums", "bass", "other", "vocals", "guitar", "piano")
FOUR_STEMS = ("drums", "bass", "other", "vocals")

SIX_STEM_MODEL = "htdemucs_6s"
FOUR_STEM_MODEL = "htdemucs"


def canonical_stems(stems) -> tuple[str, ...]:
    """Validate stem names and return them deduplicated in a stable order.

    Stable order makes output file names predictable regardless of the order
    stems were requested in.

    Args:
        stems: iterable of stem names, for example ['vocals', 'guitar'].

    Returns:
        Tuple of unique stem names ordered as in SIX_STEMS.

    Raises:
        ValueError: when no stem is given or any of them is not supported.
    """
    requested = list(stems)
    if not requested:
        raise ValueError(f"At least one stem is required. Supported stems: {', '.join(SIX_STEMS)}")
    unsupported = [stem for stem in requested if stem not in SIX_STEMS]
    if unsupported:
        raise ValueError(f"Unsupported stem(s): {', '.join(unsupported)}. Supported stems: {', '.join(SIX_STEMS)}")
    return tuple(stem for stem in SIX_STEMS if stem in requested)


def complement_stems(stems) -> tuple[str, ...]:
    """Return stems which are not in given selection.

    Args:
        stems: iterable of selected stem names.

    Returns:
        Tuple of the remaining stem names ordered as in SIX_STEMS.
    """
    selected = canonical_stems(stems)
    return tuple(stem for stem in SIX_STEMS if stem not in selected)


def model_for_stems(stems) -> str:
    """Return name of Demucs model providing all given stems.

    Args:
        stems: iterable of stem names, for example ['guitar', 'vocals'].

    Returns:
        Demucs model name.

    Raises:
        ValueError: when no bundled model provides all the stems.
    """
    canonical_stems(stems)
    return SIX_STEM_MODEL


def python_of(venv_path: Path = DEFAULT_VENV) -> Path:
    """Return path to python interpreter of Demucs virtual env.

    Args:
        venv_path: location of the virtual env.

    Returns:
        Path to the interpreter, regardless whether it already exists.
    """
    return venv_path / "bin" / "python"


def is_installed(venv_path: Path = DEFAULT_VENV) -> bool:
    """Check whether Demucs is already installed in given virtual env.

    Args:
        venv_path: location of the virtual env.

    Returns:
        True when demucs module can be imported by the virtual env interpreter.
    """
    python = python_of(venv_path)
    if not python.is_file():
        return False
    return (
        subprocess.run(
            [str(python), "-c", "import demucs"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        == 0
    )


def ensure_installed(venv_path: Path = DEFAULT_VENV) -> Path:
    """Ensure Demucs with PyTorch is installed in dedicated virtual env.

    On first run it downloads several GB of PyTorch CUDA wheels, which takes a while.

    Args:
        venv_path: location of the virtual env to create or reuse.

    Returns:
        Path to python interpreter of the virtual env.

    Raises:
        subprocess.CalledProcessError: when creating venv or installing packages fails.
    """
    python = python_of(venv_path)
    if is_installed(venv_path):
        return python

    if not python.is_file():
        print(f"Creating virtual env for demucs in {venv_path}")
        venv.create(venv_path, with_pip=True, clear=True)

    print("Installing demucs with PyTorch (first run only, downloads several GB)")
    run_streamed([python, "-m", "pip", "install", "--upgrade", "pip", "wheel"])
    run_streamed([python, "-m", "pip", "install", "numpy", "torch", "torchaudio", "demucs"])
    return python


def is_cuda_available(venv_path: Path = DEFAULT_VENV) -> bool:
    """Check whether PyTorch in Demucs virtual env can use CUDA.

    Args:
        venv_path: location of the virtual env.

    Returns:
        True when a CUDA device is usable.
    """
    result = subprocess.run(
        [str(python_of(venv_path)), "-c", "import torch; print(torch.cuda.is_available())"],
        check=False,
        encoding="UTF-8",
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    return result.stdout.strip().endswith("True")


def separate(
    audio: Path,
    stems,
    output_dir: Path,
    venv_path: Path = DEFAULT_VENV,
    device: str = "auto",
    segment: int = 7,
    shifts: int = 0,
    all_stems: bool = False,
) -> dict[str, Path]:
    """Separate requested stems out of audio file with Demucs.

    For a single stem Demucs two stems mode is used, which is faster and yields
    the stem and its complement. For more stems the full model output is produced,
    as two stems mode supports only one stem at a time.

    Args:
        audio: path to audio file to separate.
        stems: stems to extract, subset of SIX_STEMS.
        output_dir: directory where Demucs stores its output tree.
        venv_path: location of Demucs virtual env.
        device: 'cuda', 'cpu' or 'auto' to prefer CUDA when available.
        segment: length of processed chunk in seconds, lower values need less VRAM.
        shifts: number of random shifts, higher values give better quality but are slower.
        all_stems: whether to produce all model stems even for a single requested stem.

    Returns:
        Mapping of stem name to its WAV file, including 'no_<stem>' complement
        when Demucs two stems mode was used.

    Raises:
        subprocess.CalledProcessError: when Demucs fails on both CUDA and CPU.
        FileNotFoundError: when Demucs finishes but expected stem files are absent.
    """
    selected = canonical_stems(stems)
    model = model_for_stems(selected)
    python = ensure_installed(venv_path)

    if device == "auto":
        device = "cuda" if is_cuda_available(venv_path) else "cpu"

    two_stems_mode = len(selected) == 1 and not all_stems
    expected = [*selected, f"no_{selected[0]}"] if two_stems_mode else list(SIX_STEMS)

    command = [python, "-m", "demucs", "-n", model]
    if two_stems_mode:
        command += [f"--two-stems={selected[0]}"]
    command += ["-d", device, "--segment", segment, "-o", output_dir, audio]
    if shifts:
        command += ["--shifts", shifts]

    print(f"Separating {', '.join(selected)} with {model} on {device} (segment={segment}, shifts={shifts})")
    # Demucs reads HOME to locate its model cache, keep the current environment
    try:
        run_streamed(command, env=dict(os.environ))
    except subprocess.CalledProcessError:
        if device != "cuda":
            raise
        print("CUDA run failed (likely out of GPU memory), retrying on CPU")
        command[command.index("-d") + 1] = "cpu"
        run_streamed(command, env=dict(os.environ))

    result_dir = output_dir / model / audio.stem
    results = {name: result_dir / f"{name}.wav" for name in expected}
    missing = [str(path) for path in results.values() if not path.is_file()]
    if missing:
        raise FileNotFoundError(f"Demucs did not produce expected stem file(s): {', '.join(missing)}")
    return results
