// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/responsive/responsive_text.dart';
import '../widgets/responsive/responsive_sized_box.dart';
import '../widgets/responsive/responsive_container.dart';
import '../widgets/responsive/responsive_logo.dart';
import '../widgets/responsive/responsive_spacing.dart';
import '../widgets/responsive/responsive_button.dart';
import '../responsive/responsive_utils.dart';

/// Test page to verify responsive widgets work correctly across different screen sizes
class ResponsiveTestPage extends StatelessWidget {
  const ResponsiveTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Widget Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen size info
            _buildScreenInfo(context),
            ResponsiveSpacing.large,

            // Responsive text examples
            _buildSection('Responsive Text', [
              const ResponsiveText(
                'Large Text (48px base)',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              ResponsiveSpacing.medium,
              const ResponsiveText(
                'Medium Text (24px base)',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
              ResponsiveSpacing.medium,
              const ResponsiveText(
                'Small Text (14px base)',
                fontSize: 14,
                color: Colors.grey,
              ),
            ]),
            ResponsiveSpacing.large,

            // Responsive logo examples
            _buildSection('Responsive Logo', [
              const Center(
                child: ResponsiveLogo(
                  icon: Icons.shopping_bag,
                  baseSize: 120.0,
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                ),
              ),
            ]),
            ResponsiveSpacing.large,

            // Responsive spacing examples
            _buildSection('Responsive Spacing', [
              Container(
                color: Colors.blue.withOpacity(0.1),
                child: Column(
                  children: [
                    Container(
                      color: Colors.red,
                      child: ResponsiveSpacing.small,
                    ),
                    Container(
                      color: Colors.orange,
                      child: ResponsiveSpacing.medium,
                    ),
                    Container(
                      color: Colors.yellow,
                      child: ResponsiveSpacing.standard,
                    ),
                    Container(
                      color: Colors.green,
                      child: ResponsiveSpacing.large,
                    ),
                    Container(
                      color: Colors.blue,
                      child: ResponsiveSpacing.xLarge,
                    ),
                    Container(
                      color: Colors.purple,
                      child: ResponsiveSpacing.xxLarge,
                    ),
                  ],
                ),
              ),
            ]),
            ResponsiveSpacing.large,

            // Responsive button examples
            _buildSection('Responsive Buttons', [
              ResponsiveButton(
                onPressed: () {},
                expanded: true,
                child: const Text('Responsive Button'),
              ),
              ResponsiveSpacing.medium,
              ResponsiveOutlinedButton(
                onPressed: () {},
                expanded: true,
                child: const Text('Outlined Button'),
              ),
            ]),
            ResponsiveSpacing.large,

            // Responsive container examples
            _buildSection('Responsive Containers', [
              ResponsiveContainer(
                width: double.infinity,
                height: 80,
                color: Colors.blue.withOpacity(0.3),
                child: const Center(
                  child: ResponsiveText(
                    'Full Width Container',
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
              ResponsiveSpacing.medium,
              Row(
                children: [
                  Expanded(
                    child: ResponsiveContainer(
                      height: 60,
                      color: Colors.green.withOpacity(0.3),
                      child: const Center(
                        child: ResponsiveText(
                          'Flexible',
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const ResponsiveSizedBox(width: 16),
                  Expanded(
                    child: ResponsiveContainer(
                      height: 60,
                      color: Colors.orange.withOpacity(0.3),
                      child: const Center(
                        child: ResponsiveText(
                          'Flexible',
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenInfo(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            'Screen Info',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          ResponsiveSpacing.small,
          ResponsiveText(
            'Width: ${size.width.toStringAsFixed(1)}px',
            fontSize: 14,
          ),
          ResponsiveText(
            'Height: ${size.height.toStringAsFixed(1)}px',
            fontSize: 14,
          ),
          ResponsiveText(
            'Padding: ${padding.top}px top, ${padding.bottom}px bottom',
            fontSize: 14,
          ),
          ResponsiveText(
            'Type: ${ResponsiveUtils.isMobile(context) ? "Mobile" : ResponsiveUtils.isTablet(context) ? "Tablet" : "Desktop"}',
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        ResponsiveSpacing.medium,
        ...children,
      ],
    );
  }
}