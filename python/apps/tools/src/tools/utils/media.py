"""Audio and video utilities based on system ffmpeg/ffprobe commands."""

import json
import re
import subprocess
from pathlib import Path

FFMPEG = "ffmpeg"
FFPROBE = "ffprobe"

_VOLUME_PATTERN = re.compile(r"(mean_volume|max_volume):\s*(-?[\d.]+) dB")


def probe(media: Path) -> dict:
    """Return ffprobe JSON description of media file format and its streams.

    Args:
        media: path to media file.

    Returns:
        Parsed ffprobe output with 'format' and 'streams' keys.

    Raises:
        subprocess.CalledProcessError: when file cannot be read by ffprobe.
    """
    output = subprocess.check_output(
        [FFPROBE, "-v", "error", "-print_format", "json", "-show_format", "-show_streams", str(media)],
        encoding="UTF-8",
    )
    return json.loads(output)


def audio_streams(media: Path) -> list[dict]:
    """Return audio streams of media file.

    Args:
        media: path to media file.

    Returns:
        List of ffprobe audio stream descriptions, empty when file has no audio.
    """
    return [stream for stream in probe(media).get("streams", []) if stream.get("codec_type") == "audio"]


def read_tags(media: Path) -> dict[str, str]:
    """Return container level metadata tags of media file with lowercased keys.

    Args:
        media: path to media file.

    Returns:
        Mapping of tag name to its value, empty when file has no tags.
    """
    tags = probe(media).get("format", {}).get("tags", {})
    return {str(key).lower(): str(value) for key, value in tags.items()}


def duration(media: Path) -> float:
    """Return media duration in seconds.

    Args:
        media: path to media file.

    Returns:
        Duration in seconds, 0.0 when duration is unknown.
    """
    return float(probe(media).get("format", {}).get("duration", 0.0))


def extract_audio_to_wav(media: Path, wav: Path, sample_rate: int = 44100, channels: int = 2) -> Path:
    """Extract audio track of media file into lossless PCM WAV file.

    Video streams are dropped and audio is not lossy re-encoded,
    so that further processing does not degrade quality.

    Args:
        media: path to media file with at least one audio stream.
        wav: path of WAV file to create, overwritten when exists.
        sample_rate: output sample rate in Hz.
        channels: number of output channels.

    Returns:
        Path to created WAV file.

    Raises:
        subprocess.CalledProcessError: when ffmpeg fails.
    """
    wav.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            FFMPEG,
            "-y",
            "-hide_banner",
            "-loglevel",
            "error",
            "-i",
            str(media),
            "-vn",
            "-acodec",
            "pcm_s16le",
            "-ar",
            str(sample_rate),
            "-ac",
            str(channels),
            str(wav),
        ],
        check=True,
    )
    return wav


def encode_to_mp3(
    sources: Path | list[Path],
    target: Path,
    bitrate: str = "320k",
    tags: dict[str, str] | None = None,
    normalize: bool = True,
    target_loudness: float = -14.0,
) -> Path:
    """Encode one or more audio files to single MP3 file.

    When several sources are given they are summed into one track, so that for
    example guitar and vocals stems land in one MP3 while remaining instruments
    stay silent. Summing is done without ffmpeg amix input scaling, so stems keep
    their original levels relative to each other.

    Args:
        sources: path to source audio file or list of files to mix together.
        target: path of MP3 file to create, overwritten when exists.
        bitrate: libmp3lame constant bitrate, for example '320k'.
        tags: optional metadata tags to store in MP3 file.
        normalize: whether to apply single pass EBU R128 loudness normalization.
        target_loudness: integrated loudness target in LUFS used when normalize is set.

    Returns:
        Path to created MP3 file.

    Raises:
        ValueError: when no source is given.
        subprocess.CalledProcessError: when ffmpeg fails.
    """
    inputs = [sources] if isinstance(sources, Path) else list(sources)
    if not inputs:
        raise ValueError("At least one source audio file is required")

    target.parent.mkdir(parents=True, exist_ok=True)
    command = [FFMPEG, "-y", "-hide_banner", "-loglevel", "error"]
    for source in inputs:
        command += ["-i", str(source)]

    filters = []
    if len(inputs) > 1:
        filters.append(f"amix=inputs={len(inputs)}:duration=longest:normalize=0")
    if normalize:
        filters.append(f"loudnorm=I={target_loudness}:TP=-1.5:LRA=11")
    if filters:
        command += ["-filter_complex" if len(inputs) > 1 else "-af", ",".join(filters)]

    command += ["-codec:a", "libmp3lame", "-b:a", bitrate]
    for name, value in (tags or {}).items():
        command += ["-metadata", f"{name}={value}"]
    command += [str(target)]
    subprocess.run(command, check=True)
    return target


def measure_volume(audio: Path) -> dict[str, float]:
    """Measure mean and max volume of audio file.

    Args:
        audio: path to audio file.

    Returns:
        Mapping with 'mean_volume' and 'max_volume' values in dB,
        empty when ffmpeg does not report them (for example for a digitally silent file).

    Raises:
        subprocess.CalledProcessError: when ffmpeg fails.
    """
    result = subprocess.run(
        [FFMPEG, "-hide_banner", "-i", str(audio), "-af", "volumedetect", "-f", "null", "-"],
        check=True,
        encoding="UTF-8",
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    return {name: float(value) for name, value in _VOLUME_PATTERN.findall(result.stderr)}
