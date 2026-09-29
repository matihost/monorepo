#!/usr/bin/env python3
"""Extract selected instrument tracks (stems) from video or audio recording into MP3 file."""

import argparse
import sys
import tempfile
from pathlib import Path

from tools.utils import demucs, media
from tools.utils.system import ensure_commands_available
from tools.utils.version import package_version

DEFAULT_STEMS = ("guitar", "vocals")

_DESCRIPTION = f"""Extract selected instrument tracks (stems) from a recording into MP3 file.

Audio is taken from the recording losslessly, split into stems with Demucs AI model
(htdemucs_6s) and only the requested stems are mixed into the resulting MP3,
so the remaining instruments are silent.

By default {" and ".join(DEFAULT_STEMS)} are extracted and the result loudness is
normalized, as single stems are quiet compared to the full mix.

On the first run Demucs with PyTorch is installed into a dedicated virtual env
(~/.venv/demucs by default), which downloads several GB. Later runs reuse it.
NVIDIA GPU is used when available, otherwise CPU (much slower).
"""

_EPILOG = f"""Examples:
# {" + ".join(DEFAULT_STEMS)} track, normalized, written next to the input
# as Recording_{"-".join(DEFAULT_STEMS)}.mp3
extract-stem ~/Downloads/Recording.mp4

# guitar alone into given file
extract-stem -s guitar -o ~/Music/guitar.mp3 ~/Downloads/Recording.mp4

# guitar, vocals and piano together, keep original loudness
extract-stem -s guitar vocals piano --no-normalize ~/Downloads/Recording.mp4

# better quality, slower (5 shifts), keep also the remaining instruments track
extract-stem --shifts 5 --keep-rest ~/Downloads/Recording.mp4

# force CPU or lower GPU memory usage
extract-stem -d cpu ~/Downloads/Recording.mp4
extract-stem --segment 5 ~/Downloads/Recording.mp4

Supported stems: {", ".join(demucs.SIX_STEMS)}
"""


def _parse_program_argv():
    parser = argparse.ArgumentParser(
        description=_DESCRIPTION, epilog=_EPILOG, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "input", metavar="input", type=Path, help="path to recording, for example: ~/Downloads/Recording.mp4"
    )
    parser.add_argument(
        "-s",
        "--stems",
        metavar="stem",
        type=str,
        nargs="+",
        default=list(DEFAULT_STEMS),
        choices=demucs.SIX_STEMS,
        help=f"instrument tracks to extract and mix together (default: {' '.join(DEFAULT_STEMS)})",
    )
    parser.add_argument(
        "-o",
        "--output",
        metavar="output",
        type=Path,
        help="output MP3 file (default: <input directory>/<input name>_<stems>.mp3)",
    )
    parser.add_argument(
        "-b", "--bitrate", metavar="bitrate", type=str, default="320k", help="MP3 bitrate (default: 320k)"
    )
    parser.add_argument(
        "-n",
        "--normalize",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="normalize loudness to -14 LUFS, extracted stems are quiet in the mix (default: enabled)",
    )
    parser.add_argument(
        "-d",
        "--device",
        metavar="device",
        type=str,
        default="auto",
        choices=("auto", "cuda", "cpu"),
        help="device used for separation (default: auto, CUDA when available)",
    )
    parser.add_argument(
        "--segment",
        metavar="seconds",
        type=int,
        default=7,
        help="length of chunk processed at once, lower needs less GPU memory (default: 7)",
    )
    parser.add_argument(
        "--shifts",
        metavar="shifts",
        type=int,
        default=0,
        help="number of random shifts, better quality but N times slower (default: 0)",
    )
    parser.add_argument(
        "--keep-rest",
        action="store_true",
        help="save also the remaining instruments mixed together as <output name>_rest.mp3",
    )
    parser.add_argument(
        "--venv",
        metavar="path",
        type=Path,
        default=demucs.DEFAULT_VENV,
        help=f"location of Demucs virtual env (default: {demucs.DEFAULT_VENV})",
    )
    parser.add_argument("-v", "--version", action="version", version=package_version("tools"))
    return parser.parse_args()


def main():
    """Enter the program."""
    args = _parse_program_argv()
    try:
        output = extract_stems(
            source=args.input.expanduser(),
            stems=args.stems,
            output=args.output.expanduser() if args.output else None,
            bitrate=args.bitrate,
            normalize=args.normalize,
            device=args.device,
            segment=args.segment,
            shifts=args.shifts,
            keep_rest=args.keep_rest,
            venv_path=args.venv.expanduser(),
        )
    except (RuntimeError, ValueError, FileNotFoundError) as err:
        print(f"Error: {err}", file=sys.stderr)
        sys.exit(1)
    print(f"Done: {output}")


def default_output(source: Path, stems) -> Path:
    """Return default MP3 output path for given recording and stems.

    Args:
        source: path to input recording.
        stems: names of extracted stems.

    Returns:
        Path next to the input file, suffixed with the stem names.
    """
    return source.parent / f"{source.stem}_{'-'.join(demucs.canonical_stems(stems))}.mp3"


def mp3_tags(source: Path, stems, normalized: bool) -> dict[str, str]:
    """Build MP3 metadata tags for extracted stems reusing tags of source recording.

    Args:
        source: path to input recording.
        stems: names of extracted stems.
        normalized: whether loudness normalization was applied.

    Returns:
        Mapping of MP3 metadata tag names to values.
    """
    selected = demucs.canonical_stems(stems)
    source_tags = media.read_tags(source)
    title = source_tags.get("title", source.stem)
    suffix = f"{' + '.join(selected)} only"
    if normalized:
        suffix += ", normalized"
    tags = {
        "title": f"{title} ({suffix})",
        "comment": f"{', '.join(selected)} stem(s) extracted with Demucs {demucs.SIX_STEM_MODEL}",
    }
    for tag in ("artist", "album", "date", "genre"):
        if tag in source_tags:
            tags[tag] = source_tags[tag]
    return tags


def extract_stems(
    source: Path,
    stems=DEFAULT_STEMS,
    output: Path | None = None,
    bitrate: str = "320k",
    normalize: bool = True,
    device: str = "auto",
    segment: int = 7,
    shifts: int = 0,
    keep_rest: bool = False,
    venv_path: Path = demucs.DEFAULT_VENV,
) -> Path:
    """Extract selected instrument tracks from recording into single MP3 file.

    Requested stems are mixed together, so the remaining instruments are silent.

    Args:
        source: path to input recording, any container ffmpeg can read.
        stems: instrument tracks to extract, subset of demucs.SIX_STEMS.
        output: path of MP3 file to create, defaults to default_output().
        bitrate: MP3 bitrate.
        normalize: whether to normalize loudness of the result.
        device: 'auto', 'cuda' or 'cpu'.
        segment: length of chunk processed at once in seconds.
        shifts: number of random shifts used by Demucs.
        keep_rest: whether to store also the remaining instruments as separate MP3.
        venv_path: location of Demucs virtual env.

    Returns:
        Path to created MP3 file.

    Raises:
        RuntimeError: when input is invalid or required commands are missing.
        ValueError: when requested stems are not supported.
    """
    ensure_commands_available(media.FFMPEG, media.FFPROBE)
    selected = demucs.canonical_stems(stems)

    if not source.is_file():
        raise RuntimeError(f"Input file does not exist: {source}")
    if not media.audio_streams(source):
        raise RuntimeError(f"Input file has no audio stream: {source}")

    output = output or default_output(source, selected)
    if output.resolve() == source.resolve():
        raise RuntimeError("Output file would overwrite the input file, use --output")

    print(f"Processing {source} ({media.duration(source):.0f}s), extracting {' + '.join(selected)}")

    with tempfile.TemporaryDirectory(prefix="extract-stem-") as workdir:
        work = Path(workdir)
        wav = media.extract_audio_to_wav(source, work / f"{source.stem}.wav")

        separated = demucs.separate(
            audio=wav,
            stems=selected,
            output_dir=work / "stems",
            venv_path=venv_path,
            device=device,
            segment=segment,
            shifts=shifts,
            all_stems=keep_rest,
        )

        media.encode_to_mp3(
            [separated[stem] for stem in selected],
            output,
            bitrate=bitrate,
            tags=mp3_tags(source, selected, normalize),
            normalize=normalize,
        )
        _report_volume(output, selected)

        if keep_rest:
            rest = demucs.complement_stems(selected)
            rest_output = output.with_name(f"{output.stem}_rest{output.suffix}")
            media.encode_to_mp3(
                [separated[stem] for stem in rest],
                rest_output,
                bitrate=bitrate,
                tags=mp3_tags(source, rest, normalize),
                normalize=normalize,
            )
            print(f"Saved remaining instruments ({' + '.join(rest)}): {rest_output}")

    return output


def _report_volume(audio: Path, stems):
    """Print loudness of result, so that silent or too quiet results are noticeable."""
    volume = media.measure_volume(audio)
    if not volume:
        print(f"Warning: result seems to be silent, the recording may not contain: {', '.join(stems)}")
        return
    print(f"Result loudness: mean {volume.get('mean_volume')} dB, max {volume.get('max_volume')} dB")
    if volume.get("mean_volume", 0.0) < -30.0:
        print("Hint: result is quiet, rerun with --normalize to raise its loudness")


if __name__ == "__main__":
    main()
