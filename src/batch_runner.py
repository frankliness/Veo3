"""
Async batch generation using Vertex AI.
Reads prompts/prompts.txt,
submits <= MAX_CONCURRENT_JOBS operations,
respects MAX_DAILY_SECONDS quota.
"""
import asyncio
import sys
from datetime import datetime
import nest_asyncio

import vertexai
from vertexai.generative_models import GenerativeModel
from google.api_core.exceptions import ResourceExhausted

from .config import (
    MAX_DAILY_SECONDS,
    MAX_CONCURRENT_JOBS,
    OUTPUT_DIR,
    PROJECT_ID,
    REGION,
    ROOT_DIR,
)
from .utils import log_event, download

class Runner:
    def __init__(self):
        if not PROJECT_ID or not REGION:
            raise SystemExit("❌ Set GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION in .env")
        vertexai.init(project=PROJECT_ID, location=REGION)
        
        # Using a stable Gemini model for testing.
        # Replace with a Veo model when available.
        self.model = GenerativeModel("gemini-1.5-flash")
        self.used_sec = 0

    async def generate_one(self, prompt: str, sem: asyncio.Semaphore):
        async with sem:
            # Note: Quota check is a placeholder, as text generation has different limits.
            if self.used_sec + 8 > MAX_DAILY_SECONDS:
                print(f"🚦 Daily quota likely reached, skipping: {prompt[:50]}...")
                return

            print(f"⏳ Submitting job for: {prompt[:50]}...")
            try:
                # Placeholder: Generating text instead of video.
                response = await self.model.generate_content_async(
                    f"Describe an 8-second ASMR video based on this prompt: {prompt}"
                )
                
                # In a real Veo scenario, you'd poll an operation.
                # Here we just process the text response.
                
                # self.used_sec += 8 # This would be based on actual video duration
                
                outfile_path = OUTPUT_DIR / f"{datetime.utcnow().timestamp():.0f}_test.txt"
                with open(outfile_path, "w", encoding="utf-8") as f:
                    f.write(response.text)

                log_event(
                    ts=int(datetime.utcnow().timestamp()),
                    prompt=prompt,
                    uri="test_mode_no_video_uri",
                    local=str(outfile_path),
                    cost_sec=0,
                    model="gemini-1.5-flash (test)",
                    status="success_batch_test_mode"
                )
                print(f"✅ Completed (test): {outfile_path.name}")

            except ResourceExhausted as e:
                print(f"🚦 Resource exhausted for prompt '{prompt[:50]}...'. Skipping. Error: {e}")
                await asyncio.sleep(10) # Wait before trying another job
            except Exception as e:
                print(f"❌ Unexpected error for prompt '{prompt[:50]}...': {e}")

    async def run_batch(self, prompts: list[str]):
        sem = asyncio.Semaphore(MAX_CONCURRENT_JOBS)
        tasks = [self.generate_one(p.strip(), sem) for p in prompts if p.strip()]
        await asyncio.gather(*tasks, return_exceptions=True)

if __name__ == "__main__":
    nest_asyncio.apply()
    prompts_file = ROOT_DIR / "prompts" / "prompts.txt"
    if not prompts_file.exists():
        print(f"❌ Prompts file not found at {prompts_file}")
        sys.exit(1)

    prompts = prompts_file.read_text(encoding="utf-8").splitlines()
    if not prompts:
        print("❌ No prompts found in prompts.txt")
        sys.exit(1)

    print(f"📝 Found {len(prompts)} prompts. Starting batch generation (in test mode)...")
    runner = Runner()
    asyncio.run(runner.run_batch(prompts))
    print("\n🎉 Batch run complete.") 