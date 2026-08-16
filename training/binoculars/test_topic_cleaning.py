"""topic_from_text 的清理邏輯測試：這些髒污直接決定 AI 語料的題材對齊品質，
而且關係到會不會把作者／學生姓名送進第三方 API。"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from generate_ai_corpus import looks_like_header, topic_from_text  # noqa: E402


def test_strips_author_line_title_and_ligatures():
    raw = (
        "TECHNIQUES by W.M. Yang and H.C. Lin TRANSFORMATIONAL PHENOMENON IN THE "
        "FIELD OF TAYLOR-COUETTE FLOW C ircular Couette ﬂow or Taylor-Couette "
        "ﬂow is a classical problem of hydrodynamic stability."
    )
    topic = topic_from_text(raw)
    assert "Yang" not in topic and "Lin" not in topic, f"作者名外洩：{topic}"
    assert "TRANSFORMATIONAL" not in topic, f"標題殘留：{topic}"
    assert "ﬂ" not in topic, "連字未正規化"
    assert topic.startswith("Circular Couette flow"), topic


def test_keeps_ordinary_prose_intact():
    raw = "The experiment measured torque at several Reynolds numbers. Results followed theory."
    assert topic_from_text(raw).startswith("The experiment measured torque")


def test_respects_word_budget():
    raw = " ".join(f"word{i}" for i in range(500)) + "."
    assert len(topic_from_text(raw, max_words=45).split()) <= 45


def test_header_detection():
    assert looks_like_header("INTRODUCTION AND BACKGROUND OF THE STUDY")
    assert looks_like_header("by A.B. Chen and C.D. Wu")
    assert not looks_like_header(
        "This paragraph is ordinary prose written in a normal academic register."
    )


def test_never_returns_empty_even_if_all_filtered():
    raw = "ALL CAPS HEADER ONLY"
    assert topic_from_text(raw).strip(), "全被濾掉時必須退回原始內容，不能回空字串"


if __name__ == "__main__":
    for name, fn in sorted(globals().items()):
        if name.startswith("test_"):
            fn()
            print("PASS", name)
    print("\n全部通過")
