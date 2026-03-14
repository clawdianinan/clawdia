#!/usr/bin/env python3
"""
Immediate Graphic Generation Script for Fela
Uses available tools for banner/social media graphic creation
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime

class GraphicGenerator:
    def __init__(self, output_dir="generated_graphics"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def generate_from_template(self, template_type, content, style="modern"):
        """Generate graphic using template-based approach"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create design brief
        design_brief = {
            "type": template_type,
            "content": content,
            "style": style,
            "timestamp": timestamp,
            "dimensions": self._get_dimensions(template_type)
        }
        
        # Generate using available methods
        if self._check_canva_available():
            return self._generate_with_canva(design_brief)
        else:
            return self._generate_with_basic_tools(design_brief)
    
    def _get_dimensions(self, template_type):
        """Get standard dimensions for different graphic types"""
        dimensions = {
            "social_media_post": {"width": 1080, "height": 1080},
            "banner": {"width": 1200, "height": 400},
            "thumbnail": {"width": 1280, "height": 720},
            "infographic": {"width": 800, "height": 2000},
            "presentation_slide": {"width": 1920, "height": 1080}
        }
        return dimensions.get(template_type, {"width": 1080, "height": 1080})
    
    def _check_canva_available(self):
        """Check if Canva API is available"""
        # Placeholder - implement actual Canva API check
        return False
    
    def _generate_with_canva(self, design_brief):
        """Generate using Canva API"""
        # Placeholder for Canva API implementation
        print(f"[INFO] Canva generation not yet implemented for {design_brief['type']}")
        return self._generate_with_basic_tools(design_brief)
    
    def _generate_with_basic_tools(self, design_brief):
        """Generate using basic available tools (ImageMagick, etc.)"""
        try:
            # Check for ImageMagick
            result = subprocess.run(["which", "convert"], capture_output=True, text=True)
            if result.returncode == 0:
                return self._generate_with_imagemagick(design_brief)
            
            # Fallback to simple text-based generation
            return self._generate_simple_graphic(design_brief)
            
        except Exception as e:
            print(f"[ERROR] Graphic generation failed: {e}")
            return None
    
    def _generate_with_imagemagick(self, design_brief):
        """Generate using ImageMagick"""
        filename = f"{design_brief['type']}_{design_brief['timestamp']}.png"
        output_path = self.output_dir / filename
        
        # Create a simple graphic with ImageMagick
        width = design_brief["dimensions"]["width"]
        height = design_brief["dimensions"]["height"]
        
        # Extract content for display
        title = design_brief["content"].get("title", "Graphic")
        subtitle = design_brief["content"].get("subtitle", "")
        
        # Create command
        cmd = [
            "convert",
            "-size", f"{width}x{height}",
            "gradient:blue-white",
            "-font", "Helvetica",
            "-pointsize", "48",
            "-fill", "white",
            "-gravity", "center",
            "-annotate", "0", title,
            "-pointsize", "24",
            "-annotate", "+0+60", subtitle,
            str(output_path)
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"[SUCCESS] Generated graphic: {output_path}")
            return {
                "success": True,
                "path": str(output_path),
                "method": "imagemagick",
                "dimensions": f"{width}x{height}"
            }
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] ImageMagick failed: {e}")
            return None
    
    def _generate_simple_graphic(self, design_brief):
        """Generate a simple placeholder graphic"""
        filename = f"{design_brief['type']}_{design_brief['timestamp']}.txt"
        output_path = self.output_dir / filename
        
        # Create a text-based "graphic"
        width = design_brief["dimensions"]["width"] // 10  # Approximate characters
        height = design_brief["dimensions"]["height"] // 20
        
        content = f"""
        GRAPHIC DESIGN: {design_brief['type'].upper()}
        STYLE: {design_brief['style']}
        DIMENSIONS: {design_brief['dimensions']['width']}x{design_brief['dimensions']['height']}
        
        CONTENT:
        {json.dumps(design_brief['content'], indent=2)}
        
        [This is a placeholder. Install ImageMagick or connect Canva API for actual graphics.]
        """
        
        with open(output_path, 'w') as f:
            f.write(content)
        
        print(f"[INFO] Created placeholder design brief: {output_path}")
        return {
            "success": True,
            "path": str(output_path),
            "method": "placeholder",
            "note": "Install ImageMagick or connect Canva API for actual graphics"
        }
    
    def create_design_brief(self, campaign_data):
        """Create structured design brief from campaign data"""
        return {
            "campaign": campaign_data.get("name", "Unnamed Campaign"),
            "objective": campaign_data.get("objective", ""),
            "target_audience": campaign_data.get("audience", ""),
            "key_message": campaign_data.get("message", ""),
            "visual_style": campaign_data.get("style", "modern"),
            "brand_colors": campaign_data.get("colors", ["#000000", "#FFFFFF"]),
            "typography": campaign_data.get("fonts", ["Helvetica", "Arial"]),
            "call_to_action": campaign_data.get("cta", ""),
            "created_at": datetime.now().isoformat()
        }

def main():
    """Test the graphic generator"""
    generator = GraphicGenerator()
    
    # Test with sample data
    test_content = {
        "title": "Spring Campaign 2026",
        "subtitle": "Limited Time Offer - 50% Off",
        "body": "Join our exclusive spring promotion with special discounts.",
        "cta": "Shop Now"
    }
    
    # Generate different types of graphics
    graphic_types = ["social_media_post", "banner", "thumbnail"]
    
    results = []
    for gtype in graphic_types:
        print(f"\nGenerating {gtype}...")
        result = generator.generate_from_template(gtype, test_content)
        if result:
            results.append(result)
    
    # Print summary
    print(f"\n{'='*50}")
    print("GRAPHIC GENERATION SUMMARY")
    print(f"{'='*50}")
    for r in results:
        print(f"Type: {r.get('method', 'unknown')}")
        print(f"File: {r.get('path', 'N/A')}")
        print(f"Status: {'SUCCESS' if r.get('success') else 'FAILED'}")
        if r.get('note'):
            print(f"Note: {r['note']}")
        print("-" * 30)

if __name__ == "__main__":
    main()