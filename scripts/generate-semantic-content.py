#!/usr/bin/env python3
"""
Semantic Content Generator

Generates meaningful, semantically rich content with proper sentence structure
and realistic updates for testing semantic analysis and capture systems.
"""

import random
import sys
from typing import List, Optional, Tuple

# Topic categories for diverse content
TOPICS = {
    'technology': [
        'artificial intelligence', 'machine learning', 'cloud computing', 'blockchain',
        'cybersecurity', 'data science', 'web development', 'mobile apps', 'IoT',
        'quantum computing', 'virtual reality', 'augmented reality', 'automation'
    ],
    'science': [
        'climate change', 'space exploration', 'genetic research', 'medical breakthroughs',
        'renewable energy', 'astrophysics', 'neuroscience', 'biotechnology', 'chemistry',
        'mathematics', 'evolution', 'environmental science', 'physics'
    ],
    'business': [
        'startup culture', 'venture capital', 'market trends', 'economic analysis',
        'leadership strategies', 'digital transformation', 'customer experience', 'innovation',
        'entrepreneurship', 'supply chain', 'marketing strategies', 'business analytics'
    ],
    'society': [
        'education reform', 'healthcare access', 'social media impact', 'urban planning',
        'cultural diversity', 'work-life balance', 'mental health', 'sustainability',
        'social justice', 'community building', 'public policy', 'demographic changes'
    ],
    'lifestyle': [
        'fitness and wellness', 'travel experiences', 'culinary arts', 'hobbies and interests',
        'home improvement', 'personal finance', 'book reviews', 'film and entertainment',
        'music appreciation', 'outdoor activities', 'creative writing', 'photography'
    ]
}

# Sentence starters for natural flow
SENTENCE_STARTERS = [
    'Recent studies have shown that', 'Experts believe that', 'It is widely accepted that',
    'Many people are discovering that', 'Research indicates that', 'The latest findings suggest',
    'Industry leaders are recognizing that', 'A growing number of professionals are finding that',
    'Current trends demonstrate that', 'Evidence shows that', 'Analysis reveals that',
    'Observations indicate that', 'Data suggests that', 'Experience teaches us that',
    'Historically, we have seen that', 'Moving forward, it is clear that'
]

# Transition phrases
TRANSITIONS = [
    'Furthermore,', 'In addition,', 'Moreover,', 'Additionally,', 'On the other hand,',
    'However,', 'Nevertheless,', 'Meanwhile,', 'Similarly,', 'In contrast,',
    'Therefore,', 'Consequently,', 'As a result,', 'For instance,', 'Specifically,',
    'Notably,', 'Importantly,', 'Indeed,', 'In fact,', 'Consider, for example,'
]

# Action verbs for variety
ACTION_VERBS = [
    'develop', 'create', 'implement', 'analyze', 'improve', 'transform', 'optimize',
    'enhance', 'expand', 'explore', 'investigate', 'discover', 'innovate', 'design',
    'build', 'establish', 'maintain', 'manage', 'leverage', 'utilize', 'adapt'
]

# Descriptive phrases
DESCRIPTIVE_PHRASES = [
    'significantly', 'dramatically', 'gradually', 'rapidly', 'carefully', 'effectively',
    'efficiently', 'successfully', 'strategically', 'innovatively', 'thoughtfully',
    'proactively', 'systematically', 'comprehensively', 'precisely'
]


def get_random_topic() -> Tuple[str, List[str]]:
    """Get a random topic category and its keywords"""
    category = random.choice(list(TOPICS.keys()))
    keywords = TOPICS[category]
    return category, keywords


def generate_sentence(topic: str, keywords: List[str], is_continuation: bool = False) -> str:
    """Generate a meaningful sentence about a topic"""
    keyword = random.choice(keywords)
    
    if not is_continuation:
        starter = random.choice(SENTENCE_STARTERS)
        verb = random.choice(ACTION_VERBS)
        descriptor = random.choice(DESCRIPTIVE_PHRASES)
        
        templates = [
            f"{starter} {keyword} can {verb} {descriptor}.",
            f"{starter} {keyword} has become increasingly important in modern contexts.",
            f"{starter} understanding {keyword} requires a multifaceted approach.",
            f"{starter} the field of {keyword} continues to evolve rapidly.",
            f"{starter} {keyword} presents both opportunities and challenges.",
            f"{starter} {keyword} plays a crucial role in shaping our future.",
            f"{starter} {keyword} demands careful consideration and strategic planning.",
        ]
    else:
        transition = random.choice(TRANSITIONS)
        verb = random.choice(ACTION_VERBS)
        descriptor = random.choice(DESCRIPTIVE_PHRASES)
        
        templates = [
            f"{transition} {keyword} enables organizations to {verb} {descriptor}.",
            f"{transition} {keyword} has led to significant improvements in various sectors.",
            f"{transition} {keyword} requires ongoing research and development.",
            f"{transition} {keyword} offers unique perspectives on complex problems.",
            f"{transition} {keyword} can be {descriptor} applied in multiple contexts.",
            f"{transition} {keyword} represents a fundamental shift in how we approach challenges.",
            f"{transition} {keyword} benefits from collaboration and knowledge sharing.",
        ]
    
    return random.choice(templates)


def generate_paragraph(topic: str, keywords: List[str], num_sentences: int = 5) -> str:
    """Generate a coherent paragraph about a topic"""
    sentences = []
    for i in range(num_sentences):
        sentences.append(generate_sentence(topic, keywords, is_continuation=(i > 0)))
    return ' '.join(sentences)


def generate_content(num_paragraphs: int = 8, topic_category: Optional[str] = None) -> str:
    """Generate semantic content with multiple paragraphs"""
    if topic_category is None:
        topic_category, keywords = get_random_topic()
    else:
        keywords = TOPICS.get(topic_category, TOPICS['technology'])
    
    paragraphs = []
    for i in range(num_paragraphs):
        # Vary paragraph length for natural flow
        para_sentences = random.randint(4, 7)
        paragraphs.append(generate_paragraph(topic_category, keywords, para_sentences))
    
    return '\n\n'.join(paragraphs)


def generate_update(existing_content: str, update_type: str = 'auto') -> str:
    """
    Generate a semantically meaningful update to existing content.
    
    Update types:
    - 'expand': Add new paragraphs expanding on the topic
    - 'refine': Modify existing paragraphs with more detail
    - 'add_section': Add a new section with related topic
    - 'update': Update paragraphs with new information
    - 'auto': Randomly choose update type
    """
    if update_type == 'auto':
        update_type = random.choice(['expand', 'refine', 'add_section', 'update'])
    
    # Clean existing content - remove empty lines and split into paragraphs
    existing_content = existing_content.strip()
    existing_lines = [p.strip() for p in existing_content.split('\n\n') if p.strip()]
    
    if not existing_lines:
        # If no content, generate new content
        return generate_content()
    
    # Try to detect topic category from keywords
    detected_category = None
    detected_keywords = []
    for category, keywords in TOPICS.items():
        for keyword in keywords:
            if keyword.lower() in existing_content.lower():
                detected_category = category
                detected_keywords = keywords
                break
        if detected_category:
            break
    
    if not detected_category:
        detected_category, detected_keywords = get_random_topic()
    
    if update_type == 'expand':
        # Add 2-3 new paragraphs expanding on the topic (preserve existing)
        new_paragraphs = []
        for _ in range(random.randint(2, 3)):
            new_paragraphs.append(generate_paragraph(detected_category, detected_keywords, random.randint(4, 6)))
        return '\n\n'.join(existing_lines) + '\n\n' + '\n\n'.join(new_paragraphs)
    
    elif update_type == 'refine':
        # Modify some paragraphs with more detail, keep others
        paragraphs = existing_lines.copy()
        if paragraphs:
            # Refine first 1-2 paragraphs
            num_to_refine = min(random.randint(1, 2), len(paragraphs))
            for idx in range(num_to_refine):
                paragraphs[idx] = generate_paragraph(detected_category, detected_keywords, random.randint(5, 8))
        return '\n\n'.join(paragraphs)
    
    elif update_type == 'add_section':
        # Add a new section header and content (preserve existing)
        section_titles = [
            '## Recent Developments',
            '## Looking Ahead',
            '## Key Considerations',
            '## Future Implications',
            '## Additional Insights',
            '## Practical Applications'
        ]
        new_section = random.choice(section_titles) + '\n\n'
        for _ in range(random.randint(2, 4)):
            new_section += generate_paragraph(detected_category, detected_keywords, random.randint(4, 6)) + '\n\n'
        return '\n\n'.join(existing_lines) + '\n\n' + new_section.strip()
    
    elif update_type == 'update':
        # Update some paragraphs with new information, keep others
        paragraphs = existing_lines.copy()
        if paragraphs:
            # Update 30-50% of paragraphs
            num_to_update = max(1, len(paragraphs) // 3)
            if num_to_update < len(paragraphs):
                indices_to_update = random.sample(range(len(paragraphs)), num_to_update)
                for idx in indices_to_update:
                    paragraphs[idx] = generate_paragraph(detected_category, detected_keywords, random.randint(4, 7))
        return '\n\n'.join(paragraphs)
    
    return '\n\n'.join(existing_lines)


def main():
    """CLI interface for semantic content generation"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate semantic content')
    parser.add_argument('--paragraphs', type=int, default=8, help='Number of paragraphs')
    parser.add_argument('--topic', choices=list(TOPICS.keys()), help='Topic category')
    parser.add_argument('--update', action='store_true', help='Generate update content')
    parser.add_argument('--update-type', choices=['expand', 'refine', 'add_section', 'update', 'auto'],
                       default='auto', help='Type of update to generate')
    parser.add_argument('--existing-content', help='Existing content file for updates')
    
    args = parser.parse_args()
    
    if args.update and args.existing_content:
        with open(args.existing_content, 'r') as f:
            existing = f.read()
        # Remove front matter if present
        if existing.startswith('---'):
            parts = existing.split('---', 2)
            if len(parts) >= 3:
                existing = parts[2].strip()
        content = generate_update(existing, args.update_type)
    else:
        content = generate_content(args.paragraphs, args.topic)
    
    print(content)
    return 0


if __name__ == '__main__':
    sys.exit(main())

