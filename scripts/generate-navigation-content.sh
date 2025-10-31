#!/bin/bash

# Generate Navigation Pages Content
# CI/CD compatible script to generate fresh content for navigation pages
# Usage: ./scripts/generate-navigation-content.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

# Ensure script directory exists
mkdir -p "${PROJECT_ROOT}/scripts"

# Current date for "Last updated" sections
CURRENT_DATE=$(date '+%B %Y')

# Function to generate About page content
generate_about_content() {
    cat > "${PROJECT_ROOT}/about.md" << 'EOF'
---
layout: page
title: "About"
permalink: /about/
---

# About Our Company

Founded in 2018 with a mission to democratize enterprise-grade cloud technology, we've grown from a startup to a trusted platform serving thousands of organizations worldwide.

## Our Mission

We believe that every business, regardless of size, deserves access to world-class cloud infrastructure and business intelligence tools. Our platform levels the playing field, enabling organizations to compete effectively in today's digital economy.

## Our Team

Our team of 200+ engineers, product specialists, and customer success managers is dedicated to your success. We combine deep technical expertise with a genuine commitment to understanding your business needs.

## Our Values

- **Innovation First**: Continuous investment in cutting-edge technology and research
- **Customer-Centric**: Your success is our primary metric and driving force
- **Transparency**: Open communication and honest business practices in everything we do
- **Security & Privacy**: Uncompromising commitment to data protection and regulatory compliance
- **Global Perspective**: Serving diverse markets with localized solutions and support

## Industry Recognition

- **Cloud Platform of the Year 2024** (Industry Technology Awards)
- **Best Enterprise Solution** (Global Business Technology Summit)
- **Customer Choice Award 2023-2024** (Business Software Review)

## Certifications & Compliance

- SOC 2 Type II Certified
- ISO 27001 Certified
- GDPR Compliant
- HIPAA Compliant
- PCI DSS Level 1

---

*Last updated: CURRENT_DATE*
EOF
    # Handle sed differently for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/about.md"
    else
        sed -i "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/about.md"
    fi
}

# Function to generate Features page content
generate_features_content() {
    cat > "${PROJECT_ROOT}/features.md" << 'EOF'
---
layout: page
title: "Features"
permalink: /features/
---

# Key Features & Capabilities

Our comprehensive cloud platform provides enterprise-grade infrastructure, advanced analytics capabilities, and seamless integration with your existing technology stack.

## Enterprise-Grade Security & Compliance

Our platform meets the highest industry standards for data protection and regulatory compliance. With SOC 2 Type II certification, GDPR compliance, and end-to-end encryption, your sensitive business data remains secure at every level.

**Security Features:**
- Multi-layer security architecture with 24/7 threat monitoring
- Automated compliance reporting for industries including healthcare, finance, and government
- Role-based access control with granular permission management
- Regular security audits and penetration testing by third-party experts
- Zero-trust network architecture

## Advanced Analytics & Business Intelligence

Transform raw data into actionable insights with our powerful analytics engine. Real-time dashboards, customizable reports, and predictive modeling capabilities help you make data-driven decisions faster.

**Analytics Capabilities:**
- Real-time data processing with sub-second query performance
- Customizable dashboards tailored to your business needs
- Predictive analytics powered by machine learning algorithms
- Automated report generation and scheduled delivery
- API access for seamless integration with existing tools
- Advanced data visualization and interactive charts

## Scalable Infrastructure & Performance

Built on a distributed cloud architecture, our platform scales effortlessly with your business growth. Whether you're processing thousands or millions of transactions daily, performance remains consistent and reliable.

**Performance Features:**
- 99.99% uptime SLA with automatic failover capabilities
- Auto-scaling infrastructure that adapts to demand in real-time
- Global content delivery network for optimal performance worldwide
- Dedicated resources available for enterprise customers
- Performance monitoring with proactive alerting
- Data processing capacity: 50+ million transactions per day

## Seamless Integration & Automation

Connect with hundreds of popular business applications and automate complex workflows. Our integration platform supports REST APIs, webhooks, and native connectors for leading enterprise software.

**Integration Options:**
- Pre-built connectors for Salesforce, Microsoft 365, Google Workspace, and more
- Workflow automation with visual drag-and-drop builder
- Custom API development with comprehensive documentation
- Event-driven architecture for real-time synchronization
- Enterprise service bus for complex integration scenarios
- Webhook support for real-time event notifications

## Additional Capabilities

- **Multi-cloud Support**: Deploy across AWS, Azure, and Google Cloud
- **Data Backup & Recovery**: Automated backups with point-in-time recovery
- **Disaster Recovery**: Comprehensive DR plans with RTO/RPO guarantees
- **Monitoring & Alerting**: Advanced monitoring tools with customizable alerts
- **Mobile Access**: Native mobile apps for iOS and Android

---

*Last updated: CURRENT_DATE*
EOF
    # Handle sed differently for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/features.md"
    else
        sed -i "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/features.md"
    fi
}

# Function to generate Pricing page content
generate_pricing_content() {
    cat > "${PROJECT_ROOT}/pricing.md" << 'EOF'
---
layout: page
title: "Pricing"
permalink: /pricing/
---

# Pricing Plans

Choose the plan that fits your business needs. All plans include a free 30-day trial with no credit card required.

## Starter Plan - $299/month

Perfect for small teams getting started with cloud infrastructure.

**Included Features:**
- Up to 50 users
- 500 GB storage
- Standard support (business hours, Monday-Friday)
- Basic analytics dashboard
- Email support
- Core security features
- Standard integrations (5 pre-built connectors)
- Community forum access

**Best for:** Small businesses and startups with basic cloud infrastructure needs.

## Professional Plan - $799/month

Ideal for growing businesses with advanced requirements.

**Everything in Starter, plus:**
- Up to 200 users
- 2 TB storage
- Priority support (24/7)
- Advanced analytics & reporting
- Full API access included
- Custom integrations (up to 10)
- Phone & email support
- Advanced security features
- Custom dashboards
- Scheduled reports
- Performance monitoring

**Best for:** Growing businesses that need advanced features and better support.

## Enterprise Plan - Custom Pricing

Tailored solutions for large organizations with specific needs.

**Everything in Professional, plus:**
- Unlimited users
- Unlimited storage
- Dedicated account manager
- Custom SLA agreements (99.99%+ uptime)
- On-premise deployment options
- White-glove implementation services
- Custom training programs
- 24/7 dedicated support hotline
- Single sign-on (SSO) integration
- Advanced compliance features
- Custom integrations (unlimited)
- Dedicated infrastructure
- Multi-region deployment
- Custom contracts and billing

**Best for:** Large enterprises with complex requirements and compliance needs.

## Add-Ons Available

- **Additional Storage**: $50 per 500 GB/month
- **Extra Users**: $5 per user/month (Professional plan)
- **Premium Support**: Enhanced SLA with faster response times
- **Custom Training**: On-site or virtual training sessions
- **Professional Services**: Custom development and implementation

## Transparent Pricing

**All plans include:**
- ✅ Free 30-day trial (no credit card required)
- ✅ Cancel anytime
- ✅ 30-day money-back guarantee
- ✅ No setup fees
- ✅ No hidden costs
- ✅ Month-to-month or annual billing options (save 15% with annual)

## Not Sure Which Plan?

[Contact our sales team](#) for a personalized recommendation based on your specific needs and requirements.

---

*Last updated: CURRENT_DATE*
EOF
    # Handle sed differently for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/pricing.md"
    else
        sed -i "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/pricing.md"
    fi
}

# Function to generate Resources page content
generate_resources_content() {
    cat > "${PROJECT_ROOT}/resources.md" << 'EOF'
---
layout: page
title: "Resources"
permalink: /resources/
---

# Resources & Support

Access comprehensive resources to help you get the most out of our platform.

## Product Documentation

Comprehensive guides and API references to help you integrate and use our platform effectively.

- **User Guides**: Step-by-step instructions for all features
- **API Documentation**: Complete API reference with code examples
- **Integration Guides**: Detailed guides for connecting with popular tools
- **Best Practices**: Tips and recommendations from our experts
- **Release Notes**: Stay updated with the latest features and improvements

## Video Tutorials

Step-by-step training videos for all features, from basic setup to advanced configurations.

- **Getting Started Series**: Quick start guides for new users
- **Feature Deep Dives**: Detailed explanations of platform capabilities
- **Integration Tutorials**: How to connect with other systems
- **Advanced Topics**: Complex workflows and customizations
- **Case Studies**: Real-world examples from our customers

## Webinars & Events

Monthly webinars on best practices and new features. Learn from our experts and connect with other users.

- **Monthly Product Updates**: See what's new each month
- **Best Practices Sessions**: Learn optimization techniques
- **Industry Webinars**: Sector-specific insights and strategies
- **Q&A Sessions**: Get your questions answered live
- **Customer Success Stories**: Hear from other users

## Community Forum

Connect with other users, share experiences, and get answers to your questions from our active community.

- **Discussions**: Ask questions and share knowledge
- **Feature Requests**: Suggest improvements and vote on ideas
- **User Groups**: Connect with users in your industry
- **Expert Answers**: Get help from community moderators
- **Announcements**: Stay informed about platform updates

## Support Center

Search our knowledge base or contact support for assistance with any questions or issues.

- **Knowledge Base**: Searchable articles and FAQs
- **Ticket System**: Submit and track support requests
- **Live Chat**: Real-time assistance (available for Professional and Enterprise plans)
- **Video Support**: Screen sharing sessions for complex issues
- **Status Page**: Check platform status and scheduled maintenance

## Developer Resources

SDKs, sample code, and integration guides to help developers build custom solutions.

- **SDKs**: Libraries for popular programming languages
- **Sample Code**: Ready-to-use code examples
- **Integration Guides**: Step-by-step integration tutorials
- **Sandbox Environment**: Test integrations safely
- **Developer Portal**: Complete developer documentation

## Training & Certification

Enhance your skills with our comprehensive training programs.

- **Free Online Courses**: Self-paced learning modules
- **Certification Programs**: Earn recognized credentials
- **Instructor-Led Training**: Live virtual sessions
- **Custom Training**: Tailored programs for your organization
- **Workshops**: Hands-on learning sessions

## Case Studies & White Papers

Learn from real-world implementations and research.

- **Customer Success Stories**: Detailed case studies from our clients
- **White Papers**: In-depth research and analysis
- **Industry Reports**: Market insights and trends
- **Technical Papers**: Deep technical documentation

---

*Last updated: CURRENT_DATE*
EOF
    # Handle sed differently for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/resources.md"
    else
        sed -i "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/resources.md"
    fi
}

# Function to generate Contact page content
generate_contact_content() {
    cat > "${PROJECT_ROOT}/contact.md" << 'EOF'
---
layout: page
title: "Contact"
permalink: /contact/
---

# Contact Us

Ready to transform your business? Get in touch with our team. We're here to help you succeed.

## Sales Inquiries

Questions about our platform, pricing, or how we can help your business? Contact our sales team:

- **Email:** sales@example.com
- **Phone:** +1 (555) 123-4567
- **Hours:** Monday-Friday, 9 AM - 6 PM EST

**Response Time:** We typically respond within 2 hours during business hours.

## Technical Support

Need technical assistance? Our support team is ready to help.

- **Enterprise Customers:** 24/7 dedicated support hotline
- **Professional Plan:** Priority support (24/7)
- **Starter Plan:** Standard support (business hours)

**Support Channels:**
- Email: support@example.com
- Phone: +1 (555) 123-4567
- Live Chat: Available in your dashboard (Professional & Enterprise)
- Ticket System: Submit requests through our support portal

## Partnership & Integration

Interested in partnering with us or building integrations?

- **Email:** partners@example.com
- **Developer Relations:** devrel@example.com

## General Inquiries

For all other inquiries:

- **Email:** info@example.com
- **Address:** 123 Technology Drive, Suite 100, San Francisco, CA 94105

## Get Started Today

**[Start Your Free Trial →](#)**

Create your account in minutes with no credit card required. Experience the full platform capabilities for 30 days.

**Or schedule a demo** to see the platform in action with one of our experts.

## Office Locations

**Headquarters (San Francisco)**
123 Technology Drive, Suite 100
San Francisco, CA 94105
United States

**European Office (London)**
45 Innovation Square
London, EC2A 4DP
United Kingdom

**Asia-Pacific Office (Singapore)**
78 Business Tower, Level 15
Singapore 018956

---

*We're committed to responding to all inquiries within 24 hours. For urgent matters, please call our support line.*

*Last updated: CURRENT_DATE*
EOF
    # Handle sed differently for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/contact.md"
    else
        sed -i "s/CURRENT_DATE/${CURRENT_DATE}/" "${PROJECT_ROOT}/contact.md"
    fi
}

# Main execution
main() {
    echo "Generating navigation pages content..."
    
    generate_about_content
    echo "✓ Generated about.md"
    
    generate_features_content
    echo "✓ Generated features.md"
    
    generate_pricing_content
    echo "✓ Generated pricing.md"
    
    generate_resources_content
    echo "✓ Generated resources.md"
    
    generate_contact_content
    echo "✓ Generated contact.md"
    
    echo ""
    echo "All navigation pages have been generated successfully!"
    echo "Updated date: ${CURRENT_DATE}"
}

# Run main function
main "$@"

