#!/usr/bin/env python3
"""
Immediate Video Generation Script for Fela
Uses available tools for video creation and editing
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime

class VideoGenerator:
    def __init__(self, output_dir="generated_videos"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def generate_from_script(self, script_data, video_type="explainer"):
        """Generate video from script data"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create video brief
        video_brief = {
            "type": video_type,
            "script": script_data,
            "timestamp": timestamp,
            "duration": script_data.get("duration_seconds", 60),
            "aspect_ratio": self._get_aspect_ratio(video_type),
            "platform": script_data.get("platform", "general")
        }
        
        # Generate using available methods
        if self._check_ffmpeg_available():
            return self._generate_with_ffmpeg(video_brief)
        else:
            return self._generate_script_only(video_brief)
    
    def _get_aspect_ratio(self, video_type):
        """Get aspect ratio for different video types"""
        ratios = {
            "explainer": "16:9",
            "social_media": "9:16",  # Vertical for Reels/TikTok
            "tutorial": "16:9",
            "testimonial": "1:1",  # Square for social
            "ad": "16:9"
        }
        return ratios.get(video_type, "16:9")
    
    def _check_ffmpeg_available(self):
        """Check if FFmpeg is available"""
        try:
            result = subprocess.run(["which", "ffmpeg"], capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def _generate_with_ffmpeg(self, video_brief):
        """Generate video using FFmpeg"""
        filename = f"{video_brief['type']}_{video_brief['timestamp']}.mp4"
        output_path = self.output_dir / filename
        
        # Create a simple video with text overlay
        duration = video_brief["duration"]
        
        # Create a script file for reference
        script_file = self.output_dir / f"script_{video_brief['timestamp']}.txt"
        with open(script_file, 'w') as f:
            f.write(json.dumps(video_brief["script"], indent=2))
        
        # Create a simple video with FFmpeg
        # This creates a video with color background and text
        try:
            # First create a color background video
            temp_video = self.output_dir / f"temp_{video_brief['timestamp']}.mp4"
            
            cmd = [
                "ffmpeg",
                "-f", "lavfi",
                "-i", f"color=c=blue:s=1280x720:d={duration}",
                "-vf", f"drawtext=text='{video_brief['script'].get('title', 'Video')}':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2",
                "-c:v", "libx264",
                "-t", str(duration),
                "-y",  # Overwrite output
                str(temp_video)
            ]
            
            subprocess.run(cmd, check=True, capture_output=True)
            
            # Add silent audio track
            cmd = [
                "ffmpeg",
                "-i", str(temp_video),
                "-f", "lavfi",
                "-i", f"anullsrc=r=44100:cl=stereo",
                "-t", str(duration),
                "-c:v", "copy",
                "-c:a", "aac",
                "-shortest",
                "-y",
                str(output_path)
            ]
            
            subprocess.run(cmd, check=True, capture_output=True)
            
            # Clean up temp file
            if temp_video.exists():
                temp_video.unlink()
            
            print(f"[SUCCESS] Generated video: {output_path}")
            return {
                "success": True,
                "path": str(output_path),
                "script_path": str(script_file),
                "method": "ffmpeg",
                "duration": duration,
                "aspect_ratio": video_brief["aspect_ratio"]
            }
            
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] FFmpeg failed: {e}")
            return self._generate_script_only(video_brief)
    
    def _generate_script_only(self, video_brief):
        """Generate video script and storyboard only"""
        filename = f"storyboard_{video_brief['timestamp']}.json"
        output_path = self.output_dir / filename
        
        # Create detailed storyboard
        storyboard = {
            "video_type": video_brief["type"],
            "duration_seconds": video_brief["duration"],
            "aspect_ratio": video_brief["aspect_ratio"],
            "platform": video_brief["platform"],
            "script": video_brief["script"],
            "scenes": self._create_scenes(video_brief["script"]),
            "visual_descriptions": self._create_visual_descriptions(video_brief["script"]),
            "audio_plan": self._create_audio_plan(video_brief["script"]),
            "editing_notes": self._create_editing_notes(video_brief["script"]),
            "generated_at": datetime.now().isoformat()
        }
        
        with open(output_path, 'w') as f:
            json.dump(storyboard, f, indent=2)
        
        print(f"[INFO] Created detailed storyboard: {output_path}")
        return {
            "success": True,
            "path": str(output_path),
            "method": "storyboard",
            "note": "Install FFmpeg or connect video generation API for actual video",
            "next_steps": [
                "1. Use storyboard with video generation tool",
                "2. Or implement with FFmpeg for basic videos",
                "3. Connect to Higgsfield/Lovart/Manus API when available"
            ]
        }
    
    def _create_scenes(self, script_data):
        """Break script into scenes"""
        scenes = []
        content = script_data.get("content", "")
        
        # Simple scene breakdown
        lines = content.split('. ')
        for i, line in enumerate(lines[:5]):  # Limit to 5 scenes for example
            if line.strip():
                scenes.append({
                    "scene_number": i + 1,
                    "duration_seconds": 5,  # Default
                    "visual": f"Scene showing: {line.strip()}",
                    "audio": line.strip(),
                    "transition": "cut" if i == 0 else "fade"
                })
        
        return scenes
    
    def _create_visual_descriptions(self, script_data):
        """Create visual descriptions for AI video generation"""
        return {
            "style": script_data.get("visual_style", "modern clean"),
            "color_palette": script_data.get("colors", ["blue", "white", "black"]),
            "mood": script_data.get("mood", "professional"),
            "camera_style": script_data.get("camera", "dynamic cuts"),
            "text_overlay_style": script_data.get("text_style", "clean sans-serif")
        }
    
    def _create_audio_plan(self, script_data):
        """Create audio plan"""
        return {
            "voiceover": script_data.get("voiceover_type", "professional_male"),
            "background_music": script_data.get("music", "upbeat corporate"),
            "sound_effects": script_data.get("sfx", ["transition_swish", "button_click"]),
            "audio_mix": "voiceover: -3dB, music: -12dB"
        }
    
    def _create_editing_notes(self, script_data):
        """Create editing instructions"""
        return {
            "pace": script_data.get("pace", "medium"),
            "transition_style": script_data.get("transitions", "smooth cuts"),
            "text_animation": script_data.get("text_animation", "fade_in"),
            "color_grading": script_data.get("color_grading", "vibrant"),
            "output_format": script_data.get("format", "mp4_h264")
        }
    
    def create_video_brief(self, campaign_data):
        """Create structured video brief from campaign data"""
        return {
            "campaign": campaign_data.get("name", "Unnamed Campaign"),
            "video_purpose": campaign_data.get("purpose", "awareness"),
            "target_platform": campaign_data.get("platform", "multiple"),
            "target_length": campaign_data.get("duration_seconds", 60),
            "key_message": campaign_data.get("message", ""),
            "call_to_action": campaign_data.get("cta", ""),
            "brand_guidelines": campaign_data.get("brand", {}),
            "success_metrics": campaign_data.get("metrics", ["views", "engagement"]),
            "created_at": datetime.now().isoformat()
        }

def main():
    """Test the video generator"""
    generator = VideoGenerator()
    
    # Test with sample script
    test_script = {
        "title": "Product Launch Video",
        "content": "Introducing our revolutionary new product. Designed for efficiency and ease of use. Join thousands of satisfied customers. Get started today with our special offer.",
        "duration_seconds": 30,
        "visual_style": "modern tech",
        "platform": "social_media",
        "voiceover_type": "friendly_female",
        "music": "upbeat electronic"
    }
    
    # Generate video
    print("Generating video from script...")
    result = generator.generate_from_script(test_script, "explainer")
    
    # Print results
    print(f"\n{'='*50}")
    print("VIDEO GENERATION RESULTS")
    print(f"{'='*50}")
    
    if result:
        print(f"Method: {result.get('method', 'unknown')}")
        print(f"Output: {result.get('path', 'N/A')}")
        print(f"Duration: {result.get('duration', 'N/A')} seconds")
        print(f"Aspect Ratio: {result.get('aspect_ratio', 'N/A')}")
        
        if result.get('success'):
            print("Status: SUCCESS")
        else:
            print("Status: PARTIAL - Script/storyboard generated")
            
        if result.get('note'):
            print(f"\nNote: {result['note']}")
            
        if result.get('next_steps'):
            print("\nRecommended Next Steps:")
            for step in result['next_steps']:
                print(f"  {step}")
    else:
        print("Video generation failed completely")

if __name__ == "__main__":
    main()