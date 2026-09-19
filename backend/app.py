from datetime import datetime, timezone
import os
from typing import Any, Literal

from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title="Scanner P&O Backend", version="0.1.0")


EvidenceKind = Literal["FACT", "SIGNAL", "TREND", "HYPOTHESIS", "RUMOR"]


class Evidence(BaseModel):
    source: str
    source_type: str
    observed_at: str
    captured_at: str
    kind: EvidenceKind
    metric: str
    value: Any
    confidence: float = Field(ge=0, le=100)
    reference: str | None = None


class ScannerResult(BaseModel):
    scanner: str
    entity_type: str
    entity_id: str
    score: float = Field(ge=0, le=100)
    confidence: float = Field(ge=0, le=100)
    observed_at: str
    metrics: dict[str, Any] = {}
    evidence: list[Evidence] = []
    warnings: list[str] = []
    data_missing: list[str] = []


class ScanRequest(BaseModel):
    seed: str
    market: str = "US"
    demo: bool = True
    ai_providers: list[str] = Field(default_factory=list)


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/health")
def health():
    return {
        "ok": True,
        "service": "scanner-po",
        "version": "0.1.0",
        "time": now_iso(),
    }


@app.get("/ai-providers")
def ai_providers():
    providers = [
        ("openai", "OpenAI / ChatGPT", "OPENAI_API_KEY"),
        ("gemini", "Gemini", "GEMINI_API_KEY"),
        ("perplexity", "Perplexity", "PERPLEXITY_API_KEY"),
        ("claude", "Claude", "ANTHROPIC_API_KEY"),
        ("copilot", "Microsoft Copilot", None),
        ("google_ai_mode", "Google AI Mode", None),
    ]
    return {
        "providers": [
            {
                "id": provider_id,
                "name": name,
                "configured": bool(os.getenv(env_name)) if env_name else False,
                "mode": "api" if env_name else "consumer_check_adapter",
            }
            for provider_id, name, env_name in providers
        ],
        "rule": "No provider is mandatory. Zero providers marks AI Visibility as DATA_MISSING; one or more providers scan only those enabled.",
    }


@app.get("/scanners")
def scanners():
    return {
        "groups": {
            "store": [
                "store_discovery",
                "store_demand",
                "store_visibility",
                "opportunity_gap",
            ],
            "product": [
                "product_discovery",
                "trend",
                "social",
                "sales_demand",
                "ads",
                "ai_visibility",
                "competition",
                "product_reviews",
            ],
            "supply_economics": [
                "supplier",
                "supplier_reviews",
                "landed_cost",
                "cac_estimator",
                "profit_engine",
                "risk",
            ],
            "benchmark": [
                "benchmark_hunter",
                "benchmark_intelligence",
            ],
            "governance": [
                "alpha_analysis",
                "beta_analysis",
                "jeff_synthesis",
                "user_review",
            ],
        }
    }


@app.post("/scan")
def scan(request: ScanRequest):
    if not request.demo:
        return {
            "status": "MORE_DATA",
            "message": "Live adapters are not configured yet.",
            "data_missing": [
                "Provider credentials",
                "Source adapters",
                "Persistent evidence store",
            ],
        }

    return {
        "status": "ANALYZING",
        "seed": request.seed,
        "market": request.market,
        "demo": True,
        "ai_providers": request.ai_providers,
        "ai_coverage": {
            "enabled": len(request.ai_providers),
            "total_known": 6,
            "percent": round((len(request.ai_providers) / 6) * 100),
        },
        "ai_visibility_status": "DATA_MISSING" if not request.ai_providers else "PARTIAL_OR_FULL",
        "job_id": "demo-" + datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S"),
        "next": "STORE_OPPORTUNITY_SCANNER",
    }


@app.get("/opportunities")
def opportunities():
    return {
        "items": [
            {
                "id": "DEMO-001",
                "title": "Bluetooth sleep mask challenger",
                "state": "ANALYZING",
                "opportunity_score": 87,
                "confidence": 81,
                "demand": 84,
                "visibility_gap": 79,
                "supplier": 89,
                "economics": 78,
                "risk": 61,
                "data_missing": [
                    "Live multi-engine consumer check",
                    "Final landed-cost quote",
                    "Real CAC test",
                ],
            }
        ]
    }
