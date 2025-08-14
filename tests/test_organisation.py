"""Unit tests for organisation.py validation and CLI."""

import json
import sys
from pathlib import Path

import jsonschema
import pytest

from hungovercoders_template_python_package import organisation

EXAMPLES_DIR = Path(__file__).parent / "examples"
SCHEMA_PATH = (
    Path(__file__).parent.parent
    / "src"
    / "hungovercoders_template_python_package"
    / "schemas"
    / "organisation_schema.json"
)


@pytest.fixture
def valid_org_data() -> dict:
    """Fixture for valid organisation data."""
    return {
        "name": "Hungover Coders Inc.",
        "teams": [
            {"team_name": "Beer"},
            {"team_name": "Whiskey"},
            {"team_name": "Cheese"},
        ],
    }


@pytest.fixture
def invalid_org_data() -> dict:
    """Fixture for invalid organisation data."""
    return {
        "name": "Hungover Coders Inc.",
        "teams": [
            {"team_name": "Pizza"}  # Not in enum
        ],
    }


def test_validate_organisation_valid(valid_org_data: dict) -> None:
    """Test validation passes for valid data."""
    organisation.validate_organisation(valid_org_data)


def test_validate_organisation_invalid(invalid_org_data: dict) -> None:
    """Test validation fails for invalid data."""
    with pytest.raises(jsonschema.ValidationError):
        organisation.validate_organisation(invalid_org_data)


def test_cli_valid(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture,
    tmp_path: Path,
    valid_org_data: dict
) -> None:
    """Test CLI with valid input file."""
    file = tmp_path / "org.json"
    file.write_text(json.dumps(valid_org_data))
    test_args = ["prog", str(file)]
    monkeypatch.setattr(sys, "argv", test_args)
    organisation.main()
    out = capsys.readouterr().out
    assert "Validation successful" in out


def test_cli_show_schema(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture
) -> None:
    """Test CLI --show-schema prints schema and exits."""
    test_args = ["prog", "--show-schema"]
    monkeypatch.setattr(sys, "argv", test_args)
    with pytest.raises(SystemExit) as e:
        organisation.main()
    out = capsys.readouterr().out
    assert "Organisation" in out
    assert e.value.code == 0
