# Intend

**A context-aware coaching app that helps you use your phone with intention**

Intend is not a "digital detox blocker" or a punitive app. Instead, it's a supportive coach that helps you build intentional phone use habits through mindful prompts and self-efficacy building.

## 🌟 Philosophy

Based on scientific research into effective digital wellbeing interventions, Intend focuses on:

- **Context-aware coaching** - Gentle reminders at the right moment, not rigid blocking
- **Self-efficacy building** - Empowering you to make conscious choices
- **Positive framing** - Supporting your goals rather than shaming your behavior
- **Intentional friction** - Small pauses that help you use apps more mindfully

## ✨ Current Features

- 📱 **Intentional Use Monitoring** - Track apps you want to use more mindfully
- 💭 **Mindful Prompts** - Receive supportive reminders when opening tracked apps
- 🌙 **Focus Time** - Set hours when you don't want to receive prompts
- ➕ **Custom Apps** - Add any app with personalized intention prompts
- 🎨 **Modern, Dark-themed UI** - Clean, distraction-free interface
- ⚙️ **Easy Control** - Enable/disable individual apps or all monitoring

## 🚀 Roadmap

Based on [NEW_APPROACH.md](NEW_APPROACH.md), future versions will include:

### Planned Features
- **Goal Setting** - Set daily/weekly goals per app category
- **Breathing Screen** - 2-3 second intentional pause before opening apps
- **Progress Feedback** - Celebrate your wins and improvements
- **Context-Aware Timing** - Learn your usage patterns for just-in-time interventions
- **Strategic Grayscale** - Context-based screen dimming during high-risk times
- **Mental State Detection** - Infer boredom, stress, or inertia patterns
- **Personalized Messages** - LLM-generated prompts based on your state
- **Doomscrolling Detection** - Special handling for news and short-video binges

### Research-Based Approach
Intend's design is grounded in scientific evidence from:
- Time2Stop's adaptive JITAI interventions
- InteractOut's friction-based usage reduction
- MindShift's context-aware persuasion
- Multiple RCTs on goal-setting and self-efficacy

## 📦 Installation

1. Download the latest APK from the [Releases](https://github.com/arqueffe/Scroll-of-Shame/releases) page
2. Install the APK on your Android device
3. Grant the required permissions (Usage Access)
4. Enable coaching from the home screen

## 🛠 Building from Source

```bash
# Clone the repository
git clone https://github.com/arqueffe/Scroll-of-Shame.git
cd Scroll-of-Shame

# Install dependencies
flutter pub get

# Build APK
flutter build apk --release --target-platform android-arm64
```

## 🔧 How It Works

Intend uses Android's UsageStatsManager API to monitor which apps are in the foreground. When you open an app on your intention list during active hours, you'll receive a mindful prompt to help you pause and consider your intention.

Unlike traditional blockers, Intend:
- ✅ Supports your agency and decision-making
- ✅ Uses gentle friction instead of hard blocks
- ✅ Focuses on building habits, not punishment
- ❌ Never uses shaming or punitive language
- ❌ Doesn't force rigid lockouts you'll circumvent

## 📚 Technical Details

For detailed technical information about app monitoring implementation, see [MONITORING_HOW_TO.md](MONITORING_HOW_TO.md).

For the research-based approach and feature rationale, see [NEW_APPROACH.md](NEW_APPROACH.md).

## 🤝 Contributing

Contributions are welcome! Please ensure any changes align with the positive, supportive philosophy outlined in NEW_APPROACH.md.

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

Built on research from:
- Time2Stop's adaptive intervention system
- InteractOut's friction-based design
- MindShift's context-aware messaging
- Numerous RCTs on digital wellbeing interventions
