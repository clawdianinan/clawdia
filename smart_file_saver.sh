#!/bin/bash
# Smart File Saver: Save files to appropriate existing IIH folder structure

set -e

IIH_DIR="$HOME/Documents/IIH"

# Function to determine where to save a file
determine_save_location() {
    local filename="$1"
    local filetype="$2"
    local context="$3"  # email subject, description, etc.
    
    echo "Determining save location for: $filename"
    echo "Context: $context"
    echo ""
    
    # Convert to lowercase for matching
    lower_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    lower_context=$(echo "$context" | tr '[:upper:]' '[:lower:]')
    
    # 1. Check for organogram files
    if [[ "$lower_filename" == *"organogram"* ]] || [[ "$lower_context" == *"organogram"* ]]; then
        echo "📊 File type: Organogram"
        # Check for existing organogram directory
        org_dir=$(find "$IIH_DIR" -type d -name "*organogram*" -o -name "*Organogram*" 2>/dev/null | head -1)
        
        if [[ -n "$org_dir" ]]; then
            echo "✅ Found existing organogram directory: $(echo "$org_dir" | sed "s|$IIH_DIR/||")"
            echo "$org_dir"
            return 0
        else
            # Default to People-Operations structure
            default_dir="$IIH_DIR/People-Operations/01-Organizational-Structure/Organogram"
            mkdir -p "$default_dir"
            echo "📁 Creating default: People-Operations/01-Organizational-Structure/Organogram/"
            echo "$default_dir"
            return 0
        fi
    
    # 2. Check for financial files
    elif [[ "$lower_filename" == *"financial"* ]] || [[ "$lower_filename" == *"report"* ]] || [[ "$lower_context" == *"financial"* ]]; then
        echo "💰 File type: Financial/Report"
        # Look for finance directories
        finance_dir=$(find "$IIH_DIR" -type d \( -name "*finance*" -o -name "*financial*" -o -name "*report*" \) 2>/dev/null | head -1)
        
        if [[ -n "$finance_dir" ]]; then
            echo "✅ Found existing finance directory: $(echo "$finance_dir" | sed "s|$IIH_DIR/||")"
            echo "$finance_dir"
            return 0
        else
            default_dir="$IIH_DIR/Finance/Reports"
            mkdir -p "$default_dir"
            echo "📁 Creating default: Finance/Reports/"
            echo "$default_dir"
            return 0
        fi
    
    # 3. Check for HR/People files
    elif [[ "$lower_filename" == *"hr"* ]] || [[ "$lower_filename" == *"job"* ]] || [[ "$lower_filename" == *"jd"* ]] || 
         [[ "$lower_context" == *"hr"* ]] || [[ "$lower_context" == *"job"* ]]; then
        echo "👥 File type: HR/Job Description"
        hr_dir=$(find "$IIH_DIR" -type d \( -name "*hr*" -o -name "*people*" -o -name "*job*" \) 2>/dev/null | head -1)
        
        if [[ -n "$hr_dir" ]]; then
            echo "✅ Found existing HR directory: $(echo "$hr_dir" | sed "s|$IIH_DIR/||")"
            echo "$hr_dir"
            return 0
        else
            default_dir="$IIH_DIR/People-Operations/02-Roles-Responsibilities"
            mkdir -p "$default_dir"
            echo "📁 Creating default: People-Operations/02-Roles-Responsibilities/"
            echo "$default_dir"
            return 0
        fi
    
    # 4. Check for program/project files
    elif [[ "$lower_filename" == *"program"* ]] || [[ "$lower_filename" == *"project"* ]] || 
         [[ "$lower_context" == *"program"* ]] || [[ "$lower_context" == *"project"* ]]; then
        echo "📋 File type: Program/Project"
        program_dir=$(find "$IIH_DIR" -type d \( -name "*program*" -o -name "*project*" \) 2>/dev/null | head -1)
        
        if [[ -n "$program_dir" ]]; then
            echo "✅ Found existing program directory: $(echo "$program_dir" | sed "s|$IIH_DIR/||")"
            echo "$program_dir"
            return 0
        else
            default_dir="$IIH_DIR/Programs"
            mkdir -p "$default_dir"
            echo "📁 Creating default: Programs/"
            echo "$default_dir"
            return 0
        fi
    
    # 5. Check for facility/operations files
    elif [[ "$lower_filename" == *"facility"* ]] || [[ "$lower_filename" == *"operation"* ]] ||
         [[ "$lower_context" == *"facility"* ]] || [[ "$lower_context" == *"operation"* ]]; then
        echo "🏢 File type: Facility/Operations"
        facility_dir=$(find "$IIH_DIR" -type d \( -name "*facility*" -o -name "*operation*" \) 2>/dev/null | head -1)
        
        if [[ -n "$facility_dir" ]]; then
            echo "✅ Found existing facility directory: $(echo "$facility_dir" | sed "s|$IIH_DIR/||")"
            echo "$facility_dir"
            return 0
        else
            default_dir="$IIH_DIR/Operations/Facility-Management"
            mkdir -p "$default_dir"
            echo "📁 Creating default: Operations/Facility-Management/"
            echo "$default_dir"
            return 0
        fi
    
    # 6. Default to appropriate location based on file type
    else
        echo "📄 File type: General"
        
        # Check file extension for hints
        if [[ "$filename" == *.pdf ]] || [[ "$filename" == *.doc* ]] || [[ "$filename" == *.ppt* ]]; then
            # Documents likely belong in relevant department folders
            echo "📎 Document file - checking context..."
            
            if [[ -n "$context" ]]; then
                # Try to match context to known departments
                case "$lower_context" in
                    *"iih"*|*"hub"*)
                        default_dir="$IIH_DIR/Corporate"
                        ;;
                    *"governance"*|*"policy"*)
                        default_dir="$IIH_DIR/Governance"
                        ;;
                    *"admin"*|*"administration"*)
                        default_dir="$IIH_DIR/Administration"
                        ;;
                    *)
                        default_dir="$IIH_DIR/Documents"
                        ;;
                esac
            else
                default_dir="$IIH_DIR/Documents"
            fi
        else
            # Other files go to general documents
            default_dir="$IIH_DIR/Documents"
        fi
        
        mkdir -p "$default_dir"
        echo "📁 Default location: $(echo "$default_dir" | sed "s|$IIH_DIR/||")"
        echo "$default_dir"
        return 0
    fi
}

# Function to save a file with timestamp
smart_save_file() {
    local source_file="$1"
    local context="$2"
    
    if [[ ! -f "$source_file" ]]; then
        echo "❌ Source file not found: $source_file"
        return 1
    fi
    
    filename=$(basename "$source_file")
    echo ""
    echo "=== SMART SAVE: $filename ==="
    echo ""
    
    # Determine save location
    save_dir=$(determine_save_location "$filename" "" "$context")
    
    if [[ -z "$save_dir" ]]; then
        echo "❌ Could not determine save location"
        return 1
    fi
    
    # Create timestamped filename (avoid overwrites)
    base_name="${filename%.*}"
    extension="${filename##*.}"
    timestamp=$(date '+%Y%m%d_%H%M')
    
    # Check if file already exists in destination
    if [[ -f "$save_dir/$filename" ]]; then
        # File exists, create versioned copy
        new_filename="${base_name}_${timestamp}.${extension}"
        echo "⚠️ File already exists, creating versioned copy: $new_filename"
    else
        new_filename="$filename"
    fi
    
    # Copy file (never move, always copy for safety)
    cp "$source_file" "$save_dir/$new_filename"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Saved to: $(echo "$save_dir" | sed "s|$IIH_DIR/||")/$new_filename"
        echo "📏 File size: $(stat -f%z "$source_file" 2>/dev/null || echo "unknown") bytes"
        return 0
    else
        echo "❌ Failed to save file"
        return 1
    fi
}

# Example usage
echo "=== SMART FILE SAVER ==="
echo "Using existing IIH folder structure"
echo ""

# Test with organogram files
echo "1. Testing with organogram files:"
smart_save_file "$HOME/Downloads/IIH Organogram.drawio.png" "New IIH Organogram structure"

echo ""
echo "2. Testing with financial report:"
smart_save_file "$HOME/Downloads/sample.pdf" "Monthly Financial Report January 2026"

echo ""
echo "3. Testing with job description:"
smart_save_file "$HOME/Downloads/JD_Program_Officer.docx" "Job Description for Program Officer"

echo ""
echo "=== SMART SAVING RULES IMPLEMENTED ==="
echo ""
echo "✅ Now using existing IIH folder structure"
echo "✅ No more creating random new folders"
echo "✅ Files saved to appropriate departments"
echo "✅ Versioning with timestamps"
echo "✅ Never delete original files"