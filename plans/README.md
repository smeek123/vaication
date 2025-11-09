# 🏖️ Vacaition - AI-Powered Travel Planning App

Vacaition is a modern iOS app built with SwiftUI that helps users plan amazing trips through an intelligent AI chatbot interface. The app features a clean, elegant design with full dark mode support and comprehensive accessibility features.

## ✨ Features

### 🏠 Home Screen
- Welcoming interface with animated app logo
- Clear call-to-action to start trip planning
- Quick action cards for common tasks
- Recent trips overview (if available)
- Feature highlights showcasing app benefits

### 💬 AI Chatbot Interface
- Natural conversational AI assistant
- Smart trip planning with context awareness
- Mock AI responses for destinations like Paris, Tokyo, and Barcelona
- Quick reply buttons for common interactions
- Typing indicators and smooth animations
- Scrollable chat history with proper message bubbles

### 🗺️ Trip Details Screen
- Comprehensive trip overview with destination, dates, and budget
- Visual statistics (duration, hotels, activities)
- Interest tags and hotel recommendations
- Detailed itinerary with activity categories
- Interactive activity cards with cost information
- Action buttons for editing and regenerating trips

### 👤 Profile & Settings
- User profile with avatar and personal information
- Travel statistics and saved trips
- Comprehensive settings including:
  - Dark/Light mode toggle
  - Dynamic text size options
  - Reduce motion preferences
  - App information and help links

## 🎨 Design Features

### Modern UI/UX
- Clean, minimalist design with purple/blue accent colors
- Card-based layouts with soft shadows and rounded corners
- Smooth animations and transitions
- Gradient backgrounds and modern typography
- SF Symbols for consistent iconography

### Dark Mode Support
- Automatic dark/light mode switching
- Proper color adaptation for all UI elements
- User preference persistence
- System integration with iOS appearance settings

### Full Accessibility
- **VoiceOver Support**: Complete screen reader compatibility
- **Dynamic Type**: All text scales with system font size settings
- **Reduce Motion**: Respects user's motion preferences
- **High Contrast**: Proper color contrast ratios
- **Accessibility Labels**: Descriptive labels for all interactive elements

## 🏗️ Architecture

### MVVM Pattern
- **Models**: User, Trip, Message, Interest, Hotel, ItineraryItem
- **ViewModels**: ThemeManager, UserManager, ChatViewModel
- **Views**: SwiftUI views with proper separation of concerns

### Project Structure
```
Vacaition/
├── Models/
│   ├── User.swift
│   ├── Trip.swift
│   ├── Message.swift
│   └── SampleData.swift
├── ViewModels/
│   ├── UserManager.swift
│   └── ChatViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── ChatView.swift
│   ├── TripDetailsView.swift
│   └── ProfileView.swift
├── Themes/
│   ├── ThemeManager.swift
│   └── AppTheme.swift
├── Assets/
│   └── Colors.xcassets/
├── VacaitionApp.swift
├── ContentView.swift
└── Info.plist
```

## 🎯 Technical Specifications

### Requirements
- **iOS**: 17.0+
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Navigation**: NavigationStack

### Key Technologies
- SwiftUI for modern declarative UI
- Combine for reactive programming
- UserDefaults for data persistence
- SF Symbols for consistent iconography
- Dynamic Type for accessibility
- Environment objects for state management

## 🚀 Getting Started

1. **Open in Xcode**: Open the project in Xcode 15.0 or later
2. **Select Target**: Choose iPhone or iPad simulator
3. **Build & Run**: Press Cmd+R to build and run the app
4. **Test Features**: Explore all screens and try the chatbot interface

## 🧪 Sample Data

The app includes comprehensive sample data:
- **Sample Trips**: Paris, Tokyo, and Barcelona with full itineraries
- **Sample Hotels**: Various accommodation options with ratings and prices
- **Sample Activities**: Detailed itinerary items with categories and costs
- **Sample Interests**: Travel preferences like beach, culture, food, etc.
- **Mock AI Responses**: Intelligent responses for common trip planning queries

## 🎨 Color Scheme

### Light Mode
- **Primary**: Purple (#9966CC)
- **Secondary**: Blue (#4D99E6)
- **Accent**: Teal (#3399CC)
- **Background**: Light Gray (#FAFAFA)
- **Text**: Dark Gray (#333333)

### Dark Mode
- **Primary**: Light Purple (#B366DD)
- **Secondary**: Light Blue (#6699F0)
- **Accent**: Light Teal (#4DCCFF)
- **Background**: Dark Gray (#1A1A1A)
- **Text**: Light Gray (#E6E6E6)

## 🔮 Future Enhancements

- **OpenAI Integration**: Replace mock AI with real GPT API
- **Real-time Data**: Integrate with booking APIs for live hotel/flight data
- **Social Features**: Share trips with friends and family
- **Offline Support**: Cache trips for offline viewing
- **Apple Watch**: Companion app for trip reminders
- **Widgets**: Home screen widgets for upcoming trips

## 📱 Screenshots

The app features four main screens:
1. **Home**: Welcome screen with trip planning CTA
2. **Chat**: AI conversation interface for trip planning
3. **Trip Details**: Comprehensive trip overview and itinerary
4. **Profile**: User settings and saved trips

## 🤝 Contributing

This is a demo app showcasing modern iOS development practices. Feel free to use it as a reference for:
- SwiftUI best practices
- Accessibility implementation
- Dark mode support
- MVVM architecture
- Modern UI design patterns

## 📄 License

This project is for educational and demonstration purposes. Feel free to use and modify as needed.

---

**Built with ❤️ using SwiftUI and modern iOS development practices**
