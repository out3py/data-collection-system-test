#!/bin/bash

# Content Templates Library
# Generates realistic content for blog-style pages with meaningful structure

# Array of realistic paragraph templates
PARAGRAPHS=(
    "In today's fast-paced digital landscape, businesses are constantly seeking innovative solutions to stay competitive. The evolution of technology has transformed how we approach everyday challenges."
    "Understanding the core principles of effective communication is essential for success. Whether you're collaborating with team members or engaging with clients, clear messaging drives results."
    "The importance of data-driven decision making cannot be overstated. By analyzing key metrics and trends, organizations can make informed choices that lead to sustainable growth."
    "Customer satisfaction remains at the heart of every successful venture. Building strong relationships requires consistent effort and genuine commitment to understanding needs."
    "Project management methodologies have evolved significantly over the years. Modern approaches emphasize flexibility and adaptability while maintaining structure."
    "Strategic planning involves careful consideration of both short-term objectives and long-term vision. Balancing these perspectives ensures steady progress toward goals."
    "The role of automation in streamlining workflows has become increasingly prominent. By reducing manual tasks, teams can focus on higher-value activities."
    "Collaboration tools have revolutionized remote work capabilities. Teams can now work effectively across different time zones and locations."
    "Market research provides valuable insights into consumer behavior and preferences. This information guides product development and marketing strategies."
    "User experience design focuses on creating intuitive interfaces that meet user needs. Attention to detail in this area directly impacts customer satisfaction."
    "Cloud computing infrastructure enables organizations to scale their operations efficiently while reducing upfront capital expenditures. This shift has democratized access to enterprise-grade technology."
    "Security measures must be implemented at multiple layers to protect sensitive data and maintain compliance with industry regulations. Regular audits and updates are crucial for maintaining robust defenses."
    "Analytics platforms provide comprehensive insights into user behavior, enabling businesses to optimize their strategies and improve conversion rates through data-driven optimization."
    "Mobile applications have become indispensable tools for modern businesses, offering unprecedented access to services and information regardless of geographic location or time constraints."
    "Integration capabilities allow disparate systems to communicate seamlessly, reducing data silos and improving overall operational efficiency across departments and functions."
    "Content marketing strategies focus on creating valuable, relevant content that attracts and engages target audiences, ultimately driving profitable customer actions and brand loyalty."
    "Performance optimization techniques can significantly improve application responsiveness and user satisfaction, leading to better retention rates and increased user engagement."
    "Agile development methodologies promote iterative improvement and rapid response to changing requirements, enabling teams to deliver value more frequently and consistently."
    "Quality assurance processes ensure that products meet established standards before release, reducing post-launch issues and maintaining customer trust in the brand."
    "Customer feedback mechanisms provide essential insights into product performance and user satisfaction, guiding future development priorities and strategic decisions."
    "Financial planning and budgeting tools help organizations allocate resources effectively, track expenditures, and forecast future financial needs with greater accuracy."
    "Training and development programs invest in employee growth, enhancing skills and knowledge while improving job satisfaction and organizational capabilities."
    "Documentation standards ensure that knowledge is preserved and transferable, reducing dependency on individual team members and facilitating smoother onboarding processes."
    "Innovation laboratories create environments where experimentation and creative thinking can flourish, leading to breakthrough solutions and competitive advantages."
    "Sustainability initiatives demonstrate corporate responsibility while potentially reducing operational costs and improving brand reputation among environmentally conscious consumers."
)

# Array of section headings
HEADINGS=(
    "Introduction"
    "Key Features"
    "Benefits"
    "Implementation"
    "Best Practices"
    "Use Cases"
    "Conclusion"
    "Next Steps"
    "Overview"
    "Details"
    "Getting Started"
    "Advanced Features"
    "Technical Specifications"
    "Success Stories"
    "Future Roadmap"
    "Additional Resources"
    "Troubleshooting"
    "Performance Metrics"
)

# Array of list items (for bullet points)
LIST_ITEMS=(
    "Comprehensive analysis and reporting capabilities"
    "Seamless integration with existing systems and platforms"
    "24/7 customer support available through multiple channels"
    "Regular updates and feature enhancements based on user feedback"
    "Scalable architecture designed for growing business needs"
    "Enterprise-grade security measures and compliance certifications"
    "Mobile-friendly design with responsive access across devices"
    "Cost-effective pricing structure with flexible payment options"
    "Quick setup and deployment process with minimal configuration required"
    "Extensive documentation and resources including video tutorials"
    "Real-time collaboration features for distributed teams"
    "Advanced analytics dashboard with customizable reporting"
    "API access for custom integrations and automation"
    "Multi-language support for global user bases"
    "Automated backup and disaster recovery capabilities"
    "Customizable workflows and business process automation"
    "Role-based access control and permission management"
    "Performance monitoring and optimization tools"
    "Integration with popular third-party applications"
    "Dedicated account management for enterprise customers"
)

# Generate a realistic blog post content
# Parameters: page_number (for uniqueness)
generate_blog_content() {
    local page_num=$1
    
    # Generate random main heading
    local heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    local heading="${HEADINGS[$heading_idx]}"
    
    # Pick 6-10 random paragraphs for main section
    local num_paragraphs=$((6 + RANDOM % 5))
    local selected_paragraphs=()
    
    for i in $(seq 1 $num_paragraphs); do
        local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
        selected_paragraphs+=("${PARAGRAPHS[$para_idx]}")
    done
    
    # Generate date information
    local days_ago=$((RANDOM % 90))
    local article_date=$(date -v-${days_ago}d '+%Y-%m-%d' 2>/dev/null || date -d "-${days_ago} days" '+%Y-%m-%d')
    
    # Generate some numbers (prices, counts, percentages)
    local price=$((19 + RANDOM % 981))  # $19-$999
    local count=$((100 + RANDOM % 9000))  # 100-9999
    local percentage=$((50 + RANDOM % 50))  # 50-99%
    local growth_rate=$((10 + RANDOM % 40))  # 10-49%
    
    # Start building content
    local content=""
    content+="## ${heading}\n\n"
    
    # Add paragraphs to main section
    for para in "${selected_paragraphs[@]}"; do
        content+="${para}\n\n"
    done
    
    # Add a second section with more details
    local second_heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    while [ "$second_heading_idx" -eq "$heading_idx" ]; do
        second_heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    done
    local second_heading="${HEADINGS[$second_heading_idx]}"
    
    content+="## ${second_heading}\n\n"
    
    # Add 3-5 more paragraphs for second section
    local num_second_paragraphs=$((3 + RANDOM % 3))
    local second_paragraphs=()
    for i in $(seq 1 $num_second_paragraphs); do
        local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
        second_paragraphs+=("${PARAGRAPHS[$para_idx]}")
    done
    
    for para in "${second_paragraphs[@]}"; do
        content+="${para}\n\n"
    done
    
    # Add a section with numbers and statistics
    content+="### Statistics and Performance Metrics\n\n"
    content+="Recent data shows that over ${percentage}% of users reported significant improvements in their workflows. "
    content+="Our platform currently serves more than ${count} active clients worldwide across various industries. "
    content+="Starting plans begin at just \$${price} per month with flexible scaling options available. "
    content+="We've observed an average growth rate of ${growth_rate}% year-over-year in user engagement and satisfaction metrics.\n\n"
    
    # Add detailed statistics paragraph
    content+="The platform processes millions of transactions daily, maintaining an uptime of 99.9% and ensuring reliable service delivery. "
    content+="Customer retention rates have improved significantly, with over 85% of users remaining active after the first year. "
    content+="Support ticket resolution times have decreased by 40% thanks to improved documentation and automated response systems.\n\n"
    
    # Add a comprehensive list section
    local num_list_items=$((6 + RANDOM % 6))  # 6-11 items
    content+="### Key Features and Capabilities\n\n"
    
    local used_indices=()
    for i in $(seq 1 $num_list_items); do
        local item_idx
        local attempts=0
        while true; do
            item_idx=$((RANDOM % ${#LIST_ITEMS[@]}))
            # Check if already used
            local found=0
            for used in "${used_indices[@]}"; do
                if [ "$used" -eq "$item_idx" ]; then
                    found=1
                    break
                fi
            done
            if [ $found -eq 0 ] || [ $attempts -gt 20 ]; then
                break
            fi
            attempts=$((attempts + 1))
        done
        used_indices+=($item_idx)
        content+="- ${LIST_ITEMS[$item_idx]}\n"
    done
    content+="\n"
    
    # Add a third section with additional information
    local third_heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    while [ "$third_heading_idx" -eq "$heading_idx" ] || [ "$third_heading_idx" -eq "$second_heading_idx" ]; do
        third_heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    done
    local third_heading="${HEADINGS[$third_heading_idx]}"
    
    content+="## ${third_heading}\n\n"
    
    # Add 2-4 more paragraphs for third section
    local num_third_paragraphs=$((2 + RANDOM % 3))
    local third_paragraphs=()
    for i in $(seq 1 $num_third_paragraphs); do
        local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
        third_paragraphs+=("${PARAGRAPHS[$para_idx]}")
    done
    
    for para in "${third_paragraphs[@]}"; do
        content+="${para}\n\n"
    done
    
    # Add additional details section
    content+="### Additional Information\n\n"
    content+="For organizations seeking to maximize their investment, we offer comprehensive training programs and dedicated support teams. "
    content+="Our implementation specialists work closely with clients to ensure smooth transitions and optimal configuration. "
    content+="Regular webinars and community forums provide ongoing education and networking opportunities for users.\n\n"
    
    # Add footer with date
    content+="---\n\n"
    content+="*Last updated: ${article_date}*\n"
    
    echo -e "$content"
}

# Generate update modifications for existing content
# Parameters: existing_content_file
generate_content_update() {
    local content_file=$1
    
    # Read existing content (skip only the front matter, preserve everything else including footer separators)
    # Get line number of second "---" (end of front matter)
    local front_matter_end=$(grep -n "^---$" "$content_file" | sed -n '2p' | cut -d: -f1)
    
    if [ -z "$front_matter_end" ]; then
        # No front matter found, use all content
        local existing_content=$(cat "$content_file")
    else
        # Skip front matter lines (1 to front_matter_end)
        local existing_content=$(sed -n "$((front_matter_end + 1)),\$p" "$content_file")
    fi
    
    # Choose update strategy (1-4)
    local strategy=$((1 + RANDOM % 4))
    
    case $strategy in
        1)
            # Add new section
            update_add_section "$existing_content"
            ;;
        2)
            # Modify numbers/dates
            update_modify_numbers "$existing_content"
            ;;
        3)
            # Add/remove list items
            update_modify_list "$existing_content"
            ;;
        4)
            # Add new paragraphs
            update_add_paragraphs "$existing_content"
            ;;
    esac
}

# Strategy 1: Add new section
update_add_section() {
    local content="$1"
    
    local heading_idx=$((RANDOM % ${#HEADINGS[@]}))
    local new_heading="${HEADINGS[$heading_idx]}"
    
    # Add 2-4 paragraphs for the new section
    local num_paragraphs=$((2 + RANDOM % 3))
    local new_paragraphs=""
    
    for i in $(seq 1 $num_paragraphs); do
        local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
        new_paragraphs="${new_paragraphs}${PARAGRAPHS[$para_idx]}\n\n"
    done
    
    local days_ago=$((RANDOM % 30))
    local new_date=$(date -v-${days_ago}d '+%Y-%m-%d' 2>/dev/null || date -d "-${days_ago} days" '+%Y-%m-%d')
    
    # Append new section with substantial content
    echo -e "${content}\n\n"
    echo -e "## ${new_heading}\n\n"
    echo -e "${new_paragraphs}"
    echo -e "This section was added on ${new_date} to provide additional insights and updated information.\n"
    
    # Add a list to the new section
    local num_list_items=$((3 + RANDOM % 4))
    echo -e "### Highlights\n\n"
    for i in $(seq 1 $num_list_items); do
        local item_idx=$((RANDOM % ${#LIST_ITEMS[@]}))
        echo -e "- ${LIST_ITEMS[$item_idx]}\n"
    done
}

# Strategy 2: Modify numbers/dates
update_modify_numbers() {
    local content="$1"
    
    # Generate new numbers (different from original)
    local new_price=$((29 + RANDOM % 971))
    local new_count=$((100 + RANDOM % 9000))
    local new_percentage=$((60 + RANDOM % 40))
    local new_growth=$((15 + RANDOM % 35))
    
    # Replace numbers in content (preserve newlines)
    local updated=$(echo "$content" | sed "s/\$[0-9]\{1,3\}/\$${new_price}/g")
    updated=$(echo "$updated" | sed "s/[0-9]\{2\}%/${new_percentage}%/g")
    updated=$(echo "$updated" | sed "s/[0-9]\{2,4\} active clients/${new_count} active clients/g")
    updated=$(echo "$updated" | sed "s/more than [0-9]\{2,4\}/more than ${new_count}/g")
    updated=$(echo "$updated" | sed "s/[0-9]\{2\}% year-over-year/${new_growth}% year-over-year/g")
    
    # Update date
    local new_date=$(date '+%Y-%m-%d' 2>/dev/null || date +%Y-%m-%d)
    updated=$(echo "$updated" | sed "s/Last updated: [0-9-]*/Last updated: ${new_date}/")
    
    # Add substantial update note with more details
    updated="${updated}

> **Update Notice:** This content was updated with new statistics and pricing information as of ${new_date}. 
> Recent metrics show significant improvements across all key performance indicators. 
> For the latest information, please refer to our updated documentation and support resources."
    
    # Add an additional paragraph about the updates
    local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
    updated="${updated}\n\n${PARAGRAPHS[$para_idx]}"
    
    echo -e "$updated"
}

# Strategy 3: Modify list items
update_modify_list() {
    local content="$1"
    
    # Add 2-4 new list items
    local num_new_items=$((2 + RANDOM % 3))
    local new_items=""
    
    for i in $(seq 1 $num_new_items); do
        local item_idx=$((RANDOM % ${#LIST_ITEMS[@]}))
        new_items="${new_items}- ${LIST_ITEMS[$item_idx]}\n"
    done
    
    # Append new items to existing list or create new list section
    if echo "$content" | grep -q "^### Key Features"; then
        # Append to existing Key Features list
        echo -e "$content"
        echo -e "$new_items"
    elif echo "$content" | grep -q "^### Key Points"; then
        # Append to existing Key Points list
        echo -e "$content"
        echo -e "$new_items"
    else
        # Add new list section with a paragraph introduction
        echo -e "$content\n\n"
        echo -e "### Additional Features\n\n"
        local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
        echo -e "${PARAGRAPHS[$para_idx]}\n\n"
        echo -e "$new_items"
    fi
}

# Strategy 4: Add new paragraphs
update_add_paragraphs() {
    local content="$1"
    
    local num_new=$((2 + RANDOM % 4))  # 2-5 new paragraphs
    
    # Find a good insertion point (before the last section or at end)
    if echo "$content" | grep -q "^### Statistics"; then
        # Insert before Statistics section
        local before_stats=$(echo "$content" | sed '/^### Statistics/,$d')
        local after_stats=$(echo "$content" | sed '1,/^### Statistics/d')
        
        local new_content="$before_stats"
        for i in $(seq 1 $num_new); do
            local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
            new_content="${new_content}\n\n${PARAGRAPHS[$para_idx]}"
        done
        new_content="${new_content}\n\n### Statistics\n\n${after_stats}"
        
        echo -e "$new_content"
    else
        # Append at the end with additional context
        local new_content="$content"
        for i in $(seq 1 $num_new); do
            local para_idx=$((RANDOM % ${#PARAGRAPHS[@]}))
            new_content="${new_content}\n\n${PARAGRAPHS[$para_idx]}"
        done
        
        # Add a closing note
        new_content="${new_content}\n\n*This content has been expanded with additional information and insights.*"
        
        echo -e "$new_content"
    fi
}

