"""Validate the machine-readable external benchmark contract and claims."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def validate(contract: dict, report: dict) -> list[str]:
    errors: list[str] = []
    if report.get("schema_version") != contract.get("schema_version"):
        errors.append("validation schema_version does not match contract")
    if report.get("contract_id") != contract.get("contract_id"):
        errors.append("validation contract_id does not match contract")
    status = report.get("status")
    if status not in {"not_yet_externally_validated", "validated"}:
        errors.append("unknown validation status")
    if status == "validated":
        if report.get("release_gate_passed") is not True:
            errors.append("validated status requires a passed release gate")
        if not report.get("detector_signature"):
            errors.append("validated status requires detector_signature")
        if not report.get("benchmark_ids"):
            errors.append("validated status requires benchmark_ids")
        test = report.get("test") or {}
        policy = contract["policy"]
        if test.get("fpr_upper_95", 1) > policy["target_fpr"]:
            errors.append("FPR upper bound exceeds contract")
        if test.get("recall", 0) < policy["minimum_recall"]:
            errors.append("recall falls below contract")
    elif report.get("release_gate_passed") is True:
        errors.append("unvalidated status cannot pass the release gate")
    return errors


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    contract = json.loads(args.contract.read_text(encoding="utf-8"))
    report = json.loads(args.report.read_text(encoding="utf-8"))
    errors = validate(contract, report)
    if errors:
        raise SystemExit("\n".join(f"- {error}" for error in errors))
    print(f"validation evidence accepted: {report['status']}")


if __name__ == "__main__":
    main()
