"""Tests for extract-stem CLI."""

import subprocess
from pathlib import Path

import pytest

from tools.cli.extract_stem import DEFAULT_STEMS, default_output, extract_stems, mp3_tags
from tools.utils import demucs, media
from tools.utils.system import ensure_commands_available, is_command_available

FFMPEG_MISSING = not is_command_available(media.FFMPEG) or not is_command_available(media.FFPROBE)
needs_ffmpeg = pytest.mark.skipif(FFMPEG_MISSING, reason="ffmpeg/ffprobe not available")


@pytest.fixture
def sample_recording(tmp_path: Path) -> Path:
    """Create short silent-video/tone-audio MP4 recording with metadata tags."""
    recording = tmp_path / "Sample Recording.mp4"
    subprocess.run(
        [
            media.FFMPEG, "-y", "-hide_banner", "-loglevel", "error",
            "-f", "lavfi", "-i", "color=c=black:s=320x240:d=2",
            "-f", "lavfi", "-i", "sine=frequency=440:duration=2",
            "-metadata", "title=Sample Title",
            "-metadata", "artist=Sample Artist",
            "-shortest", str(recording),
        ],
        check=True,
    )  # fmt: skip
    return recording


def test_default_stems_are_guitar_and_vocals():
    """Test guitar and vocals are extracted by default."""
    assert DEFAULT_STEMS == ("guitar", "vocals")


@pytest.mark.parametrize(
    ("stems", "expected_model"),
    [
        (["guitar"], demucs.SIX_STEM_MODEL),
        (["guitar", "vocals"], demucs.SIX_STEM_MODEL),
        (["piano", "bass", "drums"], demucs.SIX_STEM_MODEL),
    ],
)
def test_model_for_stems(stems, expected_model):
    """Test model selection for supported stems."""
    assert demucs.model_for_stems(stems) == expected_model


@pytest.mark.parametrize(
    ("stems", "expected"),
    [
        (["vocals", "guitar"], ("vocals", "guitar")),
        (["guitar", "vocals"], ("vocals", "guitar")),
        (["guitar", "guitar"], ("guitar",)),
        (["piano", "drums"], ("drums", "piano")),
    ],
)
def test_canonical_stems_dedups_and_orders(stems, expected):
    """Test stems are deduplicated and ordered predictably regardless of request order."""
    assert demucs.canonical_stems(stems) == expected


@pytest.mark.parametrize(
    ("stems", "expected"),
    [
        (["guitar", "vocals"], ("drums", "bass", "other", "piano")),
        (["guitar"], ("drums", "bass", "other", "vocals", "piano")),
    ],
)
def test_complement_stems(stems, expected):
    """Test complement of selected stems."""
    assert demucs.complement_stems(stems) == expected


def test_model_for_unsupported_stem():
    """Test model selection rejects unknown stem."""
    with pytest.raises(ValueError, match="Unsupported stem"):
        demucs.model_for_stems(["trumpet"])


def test_canonical_stems_rejects_empty():
    """Test at least one stem is required."""
    with pytest.raises(ValueError, match="At least one stem"):
        demucs.canonical_stems([])


@pytest.mark.parametrize(
    ("source", "stems", "expected"),
    [
        ("/data/Recording.mp4", ["guitar"], "/data/Recording_guitar.mp3"),
        ("/data/Recording.mp4", ["guitar", "vocals"], "/data/Recording_vocals-guitar.mp3"),
        ("/data/My Song.mkv", ["vocals", "guitar"], "/data/My Song_vocals-guitar.mp3"),
    ],
)
def test_default_output(source, stems, expected):
    """Test default output path derivation."""
    assert default_output(Path(source), stems) == Path(expected)


def test_ensure_commands_available_reports_missing():
    """Test missing command detection."""
    with pytest.raises(RuntimeError, match="not-existing-command"):
        ensure_commands_available("not-existing-command")


@needs_ffmpeg
def test_read_tags_and_streams(sample_recording):
    """Test metadata and audio stream detection of a recording."""
    # when
    tags = media.read_tags(sample_recording)
    # then
    assert tags["title"] == "Sample Title"
    assert tags["artist"] == "Sample Artist"
    assert len(media.audio_streams(sample_recording)) == 1
    assert media.duration(sample_recording) == pytest.approx(2.0, abs=0.2)


@needs_ffmpeg
def test_mp3_tags_reuse_source_metadata(sample_recording):
    """Test MP3 tags are built out of source recording tags for several stems."""
    # when
    tags = mp3_tags(sample_recording, ["vocals", "guitar"], normalized=True)
    # then
    assert tags["title"] == "Sample Title (vocals + guitar only, normalized)"
    assert tags["artist"] == "Sample Artist"
    assert demucs.SIX_STEM_MODEL in tags["comment"]


@needs_ffmpeg
def test_mp3_tags_without_normalization(sample_recording):
    """Test MP3 title does not mention normalization when it is disabled."""
    # when
    tags = mp3_tags(sample_recording, ["guitar"], normalized=False)
    # then
    assert tags["title"] == "Sample Title (guitar only)"


@needs_ffmpeg
def test_extract_audio_and_encode_mp3(sample_recording, tmp_path):
    """Test lossless audio extraction and MP3 encoding of the result."""
    # when
    wav = media.extract_audio_to_wav(sample_recording, tmp_path / "out.wav")
    mp3 = media.encode_to_mp3(wav, tmp_path / "out.mp3", bitrate="128k", tags={"title": "Tone"}, normalize=False)
    # then
    assert media.audio_streams(wav)[0]["codec_name"] == "pcm_s16le"
    assert media.audio_streams(mp3)[0]["codec_name"] == "mp3"
    assert media.read_tags(mp3)["title"] == "Tone"
    assert media.measure_volume(mp3)["max_volume"] < 0.1


@needs_ffmpeg
def test_encode_to_mp3_mixes_several_sources(tmp_path):
    """Test several stems are summed into one track keeping their levels."""
    # given two quiet tones of different frequency
    tones = []
    for index, frequency in enumerate((440, 880)):
        tone = tmp_path / f"tone{index}.wav"
        subprocess.run(
            [media.FFMPEG, "-y", "-hide_banner", "-loglevel", "error",
             "-f", "lavfi", "-i", f"sine=frequency={frequency}:duration=1",
             "-af", "volume=-12dB", str(tone)],
            check=True,
        )  # fmt: skip
        tones.append(tone)
    # when
    single = media.encode_to_mp3(tones[0], tmp_path / "single.mp3", normalize=False)
    mixed = media.encode_to_mp3(tones, tmp_path / "mixed.mp3", normalize=False)
    # then sum of both tones is louder than a single one, so amix did not scale inputs down
    assert media.measure_volume(mixed)["max_volume"] > media.measure_volume(single)["max_volume"]
    assert media.duration(mixed) == pytest.approx(1.0, abs=0.2)


@needs_ffmpeg
def test_encode_to_mp3_normalizes_by_default(tmp_path):
    """Test quiet source is made louder by default normalization."""
    # given very quiet tone
    quiet = tmp_path / "quiet.wav"
    subprocess.run(
        [media.FFMPEG, "-y", "-hide_banner", "-loglevel", "error",
         "-f", "lavfi", "-i", "sine=frequency=440:duration=3",
         "-af", "volume=-40dB", str(quiet)],
        check=True,
    )  # fmt: skip
    # when
    normalized = media.encode_to_mp3(quiet, tmp_path / "normalized.mp3")
    as_is = media.encode_to_mp3(quiet, tmp_path / "as_is.mp3", normalize=False)
    # then
    assert media.measure_volume(normalized)["mean_volume"] > media.measure_volume(as_is)["mean_volume"] + 10


def test_encode_to_mp3_rejects_no_source(tmp_path):
    """Test at least one source is required for encoding."""
    with pytest.raises(ValueError, match="At least one source"):
        media.encode_to_mp3([], tmp_path / "out.mp3")


@needs_ffmpeg
def test_extract_stems_rejects_file_without_audio(tmp_path):
    """Test recording without audio stream is rejected."""
    # given
    video = tmp_path / "silent.mp4"
    subprocess.run(
        [media.FFMPEG, "-y", "-hide_banner", "-loglevel", "error",
         "-f", "lavfi", "-i", "color=c=black:s=320x240:d=1", str(video)],
        check=True,
    )  # fmt: skip
    # then
    with pytest.raises(RuntimeError, match="no audio stream"):
        extract_stems(video)


def test_extract_stems_rejects_missing_input(tmp_path):
    """Test non existing input is rejected."""
    with pytest.raises(RuntimeError, match="does not exist"):
        extract_stems(tmp_path / "absent.mp4")


def test_extract_stems_rejects_unsupported_stem(tmp_path):
    """Test unsupported stem is rejected before any processing."""
    with pytest.raises(ValueError, match="Unsupported stem"):
        extract_stems(tmp_path / "absent.mp4", stems=["trumpet"])
