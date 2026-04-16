import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:huajuan_agenda/features/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsAiPage extends ConsumerStatefulWidget {
  const SettingsAiPage({super.key});

  @override
  ConsumerState<SettingsAiPage> createState() => _SettingsAiPageState();
}

class _SettingsAiPageState extends ConsumerState<SettingsAiPage> {
  late final TextEditingController _aiBaseUrlController;
  late final TextEditingController _aiApiKeyController;
  late final TextEditingController _aiModelController;
  late final TextEditingController _aiSystemPromptController;

  @override
  void initState() {
    super.initState();
    _aiBaseUrlController = TextEditingController();
    _aiApiKeyController = TextEditingController();
    _aiModelController = TextEditingController();
    _aiSystemPromptController = TextEditingController();
  }

  @override
  void dispose() {
    _aiBaseUrlController.dispose();
    _aiApiKeyController.dispose();
    _aiModelController.dispose();
    _aiSystemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final l10n = context.l10n;
    _syncAiControllers(state.aiSettings);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(l10n.settingsAiSectionTitle),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              children: [
                SettingsFlatInputRow(
                  label: l10n.settingsAiBaseUrlLabel,
                  child: TextField(
                    controller: _aiBaseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.openai.com/v1',
                    ),
                  ),
                ),
                SettingsFlatInputRow(
                  label: l10n.settingsAiApiKeyLabel,
                  child: TextField(
                    controller: _aiApiKeyController,
                    obscureText: true,
                  ),
                ),
                SettingsFlatInputRow(
                  label: l10n.settingsAiModelLabel,
                  child: TextField(
                    controller: _aiModelController,
                    decoration: const InputDecoration(
                      hintText: 'gpt-4o-mini',
                    ),
                  ),
                ),
                SettingsFlatInputRow(
                  label: l10n.settingsAiSystemPromptLabel,
                  child: TextField(
                    controller: _aiSystemPromptController,
                    minLines: 3,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            SettingsFlatSection(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ui.OutlineButton(
                          onPressed:
                              state.aiConnectionStatus == SettingsAiConnectionStatus.testing
                              ? null
                              : _testAiConnection,
                          child: Text(
                            state.aiConnectionStatus == SettingsAiConnectionStatus.testing
                                ? l10n.settingsAiTestingButton
                                : l10n.settingsAiTestButton,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ui.PrimaryButton(
                          onPressed: _saveAiSettings,
                          child: Text(l10n.settingsAiSaveButton),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.aiConnectionMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.aiConnectionMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: switch (state.aiConnectionStatus) {
                            SettingsAiConnectionStatus.success => Colors.green.shade700,
                            SettingsAiConnectionStatus.failure =>
                              Theme.of(context).colorScheme.error,
                            _ => Theme.of(context).colorScheme.onSurfaceVariant,
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAiSettings() {
    return ref.read(settingsViewModelProvider.notifier).saveAiSettings(
      _buildDraftAiSettings(),
    );
  }

  Future<void> _testAiConnection() {
    return ref.read(settingsViewModelProvider.notifier).testAiConnection(
      _buildDraftAiSettings(),
    );
  }

  void _syncAiControllers(AiSettings settings) {
    _syncController(_aiBaseUrlController, settings.baseUrl);
    _syncController(_aiApiKeyController, settings.apiKey);
    _syncController(_aiModelController, settings.model);
    _syncController(_aiSystemPromptController, settings.systemPrompt);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  AiSettings _buildDraftAiSettings() {
    final current = ref.read(settingsViewModelProvider).aiSettings;
    return current.copyWith(
      baseUrl: _aiBaseUrlController.text.trim(),
      apiKey: _aiApiKeyController.text.trim(),
      model: _aiModelController.text.trim(),
      systemPrompt: _aiSystemPromptController.text.trim(),
    );
  }
}
