import unittest

from validate_release_evidence import validate


CONTRACT = {
    "schema_version": 1,
    "contract_id": "truthlens-external-v1",
    "policy": {"target_fpr": 0.01, "minimum_recall": 0.5},
}


class ReleaseEvidenceTest(unittest.TestCase):
    def test_honest_unvalidated_state_is_valid(self) -> None:
        report = {
            "schema_version": 1,
            "contract_id": "truthlens-external-v1",
            "status": "not_yet_externally_validated",
            "release_gate_passed": False,
        }
        self.assertEqual(validate(CONTRACT, report), [])

    def test_validated_claim_needs_traceable_passing_report(self) -> None:
        report = {
            "schema_version": 1,
            "contract_id": "truthlens-external-v1",
            "status": "validated",
            "release_gate_passed": True,
            "test": {"fpr_upper_95": 0.02, "recall": 0.8},
        }
        errors = validate(CONTRACT, report)
        self.assertIn("validated status requires detector_signature", errors)
        self.assertIn("validated status requires benchmark_ids", errors)
        self.assertIn("FPR upper bound exceeds contract", errors)


if __name__ == "__main__":
    unittest.main()
