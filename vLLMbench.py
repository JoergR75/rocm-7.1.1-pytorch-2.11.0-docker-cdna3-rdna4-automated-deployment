# ---------------------------------------------------------------------------------------------------------------
# This Python script benchmarks the performance of large language models using vLLM on AMD ROCm-compatible GPUs.
# It measures throughput, latency, and time-to-first-token (TTFT) for different concurrency levels when
# generating text from a given prompt
# ---------------------------------------------------------------------------------------------------------------
# Key features:
#  - Loads a specified LLM (e.g., speakleash/Bielik-11B-v3-Base-20250730)
#  - Sends asynchronous text generation requests using AsyncLLMEngine
#  - Evaluates performance across multiple concurrency levels (1, 2, 4, 8, 16, 32)
#  - Tracks metrics: prompt tokens, generated tokens, latency, TTFT, and success rate
#  - Outputs a formatted table showing generation throughput, prompt throughput, min/max TTFT, and success rate
#  - Displays GPU and PyTorch/ROCm environment details
#  - Supports Hugging Face authentication via a token
# ---------------------------------------------------------------------------------------------------------------
# Author:                Joerg Roskowetz
# Estimated Runtime:     ~1-2 minutes (depending on model)
# Last Updated:          January 21st, 2026
# ================================================================================================================

import asyncio
import argparse
import os
from vllm import AsyncLLMEngine, SamplingParams
from vllm.engine.arg_utils import AsyncEngineArgs
import time
from tabulate import tabulate  # optional
import torch

# MODEL_NAME = "NousResearch/Hermes-4-14B" # Qwen 3
# MODEL_NAME = "NousResearch/Llama-2-7b-hf"
# MODEL_NAME = "NousResearch/DeepHermes-3-Llama-3-8B-Preview"
# MODEL_NAME = "speakleash/Bielik-11B-v2"
MODEL_NAME = "speakleash/Bielik-11B-v3-Base-20250730"
# MODEL_NAME = "speakleash/Bielik-1.5B-v3"

PROMPT = "Explain the benefits of AMD ROCm for large language models."
CONCURRENCY_LEVELS = [1, 2, 4, 8, 16, 32]
GENERATE_TOKENS = 200
PROMPT_TOKENS = 128


def parse_args():
    parser = argparse.ArgumentParser(description="vLLM benchmark")
    parser.add_argument(
        "--hf-token",
        type=str,
        default=None,
        help="Hugging Face access token"
    )
    return parser.parse_args()


async def run_request(engine, request_id: int):
    start = time.time()
    first_token_time = None
    output_tokens = 0

    async for output in engine.generate(
        PROMPT,
        SamplingParams(max_tokens=GENERATE_TOKENS),
        request_id=str(request_id),
    ):
        if first_token_time is None:
            first_token_time = time.time()
        output_tokens = len(output.outputs[0].token_ids)

    end = time.time()

    return {
        "success": True,
        "prompt_tokens": PROMPT_TOKENS,
        "generated_tokens": output_tokens,
        "latency": end - start,
        "ttft": first_token_time - start if first_token_time else None,
    }


async def benchmark():
    engine_args = AsyncEngineArgs(
        model=MODEL_NAME,
        dtype="float16",
        max_model_len=4096,
        gpu_memory_utilization=0.9,
    )

    engine = AsyncLLMEngine.from_engine_args(engine_args)

    table = []

    for concurrency in CONCURRENCY_LEVELS:
        start_batch = time.time()
        tasks = [asyncio.create_task(run_request(engine, i)) for i in range(concurrency)]
        results = await asyncio.gather(*tasks)
        end_batch = time.time()

        successes = [r for r in results if r["success"]]
        success_rate = len(successes) / concurrency * 100.0

        if successes:
            total_gen_tokens = sum(r["generated_tokens"] for r in successes)
            total_prompt_tokens = sum(r["prompt_tokens"] for r in successes)
            gen_throughput = total_gen_tokens / (end_batch - start_batch)
            prompt_throughput = total_prompt_tokens / (end_batch - start_batch)
            ttfts = [r["ttft"] for r in successes if r["ttft"] is not None]
            min_ttft = min(ttfts)
            max_ttft = max(ttfts)
        else:
            gen_throughput = 0.0
            prompt_throughput = 0.0
            min_ttft = 0.0
            max_ttft = 0.0

        table.append([
            concurrency,
            f"{gen_throughput:.2f}",
            f"{prompt_throughput:.2f}",
            f"{min_ttft:.2f}",
            f"{max_ttft:.2f}",
            f"{success_rate:.2f}%",
        ])

    headers = [
        "Batch size",
        "Generation Throughput (tokens/s)",
        "Prompt Throughput (tokens/s)",
        "Min TTFT (s)",
        "Max TTFT (s)",
        "Success Rate",
    ]

    print("\nPyTorch and ROCm version:", torch.__version__)
    print("GPU Name:", torch.cuda.get_device_name(0) if torch.cuda.device_count() > 0 else "No GPU detected")
    print("GPU VRAM:", torch.cuda.get_device_properties(0).total_memory / 1e9, "GB")
    print("\n" + tabulate(table, headers=headers, tablefmt="github"), "\n")


if __name__ == "__main__":
    args = parse_args()

    if args.hf_token:
        os.environ["HF_TOKEN"] = args.hf_token
        os.environ["HUGGINGFACE_HUB_TOKEN"] = args.hf_token  # compatibility

    asyncio.run(benchmark())
