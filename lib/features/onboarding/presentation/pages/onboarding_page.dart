import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/di/injection_container.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();

  bool _isSaving = false;

  String? _selectedCountry = 'Egypt';
  String? _selectedCity = 'Cairo';

  final Map<String, List<String>> _countriesAndCities = {
    'Egypt': [
      'Cairo',
      'Giza',
      'Alexandria',
      'Mansoura',
      'Tanta',
      'Asyut',
      'Ismailia',
      'Suez',
      'Luxor',
      'Aswan',
    ],
    'Saudi Arabia': [
      'Riyadh',
      'Jeddah',
      'Makkah',
      'Madinah',
      'Dammam',
      'Taif',
    ],
    'United Arab Emirates': [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
    ],
    'Kuwait': [
      'Kuwait City',
      'Hawalli',
      'Salmiya',
    ],
    'Qatar': [
      'Doha',
      'Al Wakrah',
      'Al Rayyan',
    ],
    'Jordan': [
      'Amman',
      'Zarqa',
      'Irbid',
      'Aqaba',
    ],
    'Morocco': [
      'Casablanca',
      'Rabat',
      'Marrakesh',
      'Tangier',
    ],
    'United Kingdom': [
      'London',
      'Manchester',
      'Birmingham',
      'Liverpool',
    ],
    'United States': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }

    if (_selectedCountry == null || _selectedCity == null) {
      _showMessage('Please select your country and city');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final preferences = sl<SharedPreferences>();

      await preferences.setString('profile_name', name);
      await preferences.setString(
        'profile_country',
        _selectedCountry!,
      );
      await preferences.setString(
        'profile_city',
        _selectedCity!,
      );

      await sl<ThemeCubit>().updateLocation(
        city: _selectedCity!,
        country: _selectedCountry!,
      );

      await preferences.setBool('profile_completed', true);

      if (!mounted) return;

      context.go('/home');
    } catch (error) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final cities = _countriesAndCities[_selectedCountry] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  Icon(
                    Icons.nightlight_round,
                    size: 65,
                    color: colors.primary,
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Welcome to Hidaya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Your journey to peace starts here.\n'
                        'Let us personalize your experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 38),

                  Text(
                    'What should we call you?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Choose your country',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.public),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _countriesAndCities.keys.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (country) {
                      if (country == null) return;

                      setState(() {
                        _selectedCountry = country;
                        _selectedCity =
                            _countriesAndCities[country]!.first;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Choose your city',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_city),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (city) {
                      setState(() {
                        _selectedCity = city;
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'You can enjoy your personalized prayer times '
                        'and daily experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}