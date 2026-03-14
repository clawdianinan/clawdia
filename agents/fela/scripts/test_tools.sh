#!/bin/bash
# Test script for Fela's immediate tool capabilities

echo "=== TESTING FELA'S GRAPHIC/VIDEO TOOLS ==="
echo "Timestamp: $(date)"
echo ""

# Check tool availability
echo "1. TOOL AVAILABILITY CHECK"
echo "-------------------------"
which ffmpeg && echo "✅ FFmpeg is installed" || echo "❌ FFmpeg not found"
which convert && echo "✅ ImageMagick is installed" || echo "❌ ImageMagick not found"
python3 --version && echo "✅ Python 3 is available" || echo "❌ Python 3 not found"
node --version && echo "✅ Node.js is available" || echo "❌ Node.js not found"
echo ""

# Test graphic generation
echo "2. GRAPHIC GENERATION TEST"
echo "-------------------------"
cd ~/.openclaw/workspace/agents/fela
python3 scripts/graphic_generator.py 2>&1 | tail -20
echo ""

# Test video generation
echo "3. VIDEO GENERATION TEST"
echo "------------------------"
python3 scripts/video_generator.py 2>&1 | tail -20
echo ""

# Check generated files
echo "4. GENERATED FILES"
echo "-----------------"
find . -name "generated_*" -type d | while read dir; do
  echo "Directory: $dir"
  find "$dir" -type f -name "*.txt" -o -name "*.json" -o -name "*.mp4" 2>/dev/null | head -5
done
echo ""

# Test FFmpeg directly
echo "5. FFMPEG DIRECT TEST"
echo "---------------------"
if which ffmpeg >/dev/null; then
  echo "Creating test video..."
  ffmpeg -f lavfi -i color=c=green:s=640x360:d=1 -t 1 test_output.mp4 2>/dev/null
  if [ -f test_output.mp4 ]; then
    echo "✅ Test video created: test_output.mp4"
    rm test_output.mp4
  else
    echo "❌ Test video creation failed"
  fi
fi
echo ""

# MCP server check
echo "6. MCP SERVER CHECK"
echo "------------------"
if [ -f "mcp_server/server.js" ]; then
  echo "✅ MCP server file exists"
  echo "Tools available in MCP server:"
  grep -n "name:" mcp_server/server.js | head -10
else
  echo "❌ MCP server file not found"
fi
echo ""

echo "=== TEST COMPLETE ==="
echo ""
echo "NEXT ACTIONS:"
echo "1. Install ImageMagick for better graphic generation: brew install imagemagick"
echo "2. Research Canva API access for professional graphics"
echo "3. Investigate video generation APIs (Higgsfield/Lovart/Manus)"
echo "4. Test MCP server integration with OpenClaw"
echo "5. Create sample campaign to test full workflow"