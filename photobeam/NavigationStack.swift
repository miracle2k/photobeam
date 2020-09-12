//
//  NavigationStack.swift
//
// Based on https://github.com/biobeats/swiftui-navigation-stack/blob/master/Sources/NavigationStack/NavigationStack.swift
// It's because our own custom animations are not possible with the default NavigationController.
//

import SwiftUI
import Combine


public struct ScreenDefinition {
    var id: String
    var backgroundColor: Color
    var righthandColor: Color
    var screen: AnyView
}


/// The transition type for the whole NavigationStackView.
public enum NavigationTransition {
    /// Transitions won't be animated.
    case none

    /// Use the [default transition](x-source-tag://defaultTransition).
    case `default`

    /// Use a custom transition (the transition will be applied both to push and pop operations).
    case custom(AnyTransition)

    /// A right-to-left slide transition on push, a left-to-right slide transition on pop.
    /// - Tag: defaultTransition
    public static var defaultTransitions: (push: AnyTransition, pop: AnyTransition) {
        let pushTrans = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        let popTrans = AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        return (pushTrans, popTrans)
    }
}

private enum NavigationType {
    case push
    case pop
}

/// Defines the type of a pop operation.
public enum PopDestination {
    /// Pop back to the previous view.
    case previous

    /// Pop back to the root view (i.e. the first view added to the NavigationStackView during the initialization process).
    case root

    /// Pop back to a view identified by a specific ID.
    case view(withId: String)
}

// MARK: ViewModel
public class NavigationStack: ObservableObject {
    fileprivate private(set) var navigationType = NavigationType.pop
    /// Customizable easing to apply in pop and push transitions
    private let easing: Animation
    
    init(easing: Animation) {
        self.easing = easing
    }
    
    // Because ViewStack is a struct, didSet will actually trigger on every mutation (the struct is replaced)
    private var viewStack = ViewStack() {
        didSet {
            currentView = viewStack.peek()
        }
    }

    @Published fileprivate var currentView: ViewElement?

    /// Navigates to a view.
    /// - Parameters:
    ///   - element: The destination view.
    ///   - identifier: The ID of the destination view (used to easily come back to it if needed).
    public func push(_ element: ScreenDefinition, withId identifier: String? = nil) {
        withAnimation(easing) {
            navigationType = .push
            viewStack.push(ViewElement(id: identifier == nil ? UUID().uuidString : identifier!,
                                       screen: element))
        }
    }

    /// Navigates back to a previous view.
    /// - Parameter to: The destination type of the transition operation.
    public func pop(to: PopDestination = .previous) {
        withAnimation(easing) {
            navigationType = .pop
            switch to {
            case .root:
                viewStack.popToRoot()
            case .view(let viewId):
                viewStack.popToView(withId: viewId)
            default:
                viewStack.popToPrevious()
            }
        }
    }

    // The data for a stack
    private struct ViewStack {
        private var views = [ViewElement]()

        func peek() -> ViewElement? {
            views.last
        }

        mutating func push(_ element: ViewElement) {
            guard indexForView(withId: element.id) == nil else {
                print("Duplicated view identifier: \"\(element.id)\". You are trying to push a view with an identifier that already exists on the navigation stack.")
                return
            }
            views.append(element)
        }

        mutating func popToPrevious() {
            _ = views.popLast()
        }

        mutating func popToView(withId identifier: String) {
            guard let viewIndex = indexForView(withId: identifier) else {
                print("Identifier \"\(identifier)\" not found. You are trying to pop to a view that doesn't exist.")
                return
            }
            views.removeLast(views.count - (viewIndex + 1))
        }

        mutating func popToRoot() {
            views.removeAll()
        }

        private func indexForView(withId identifier: String) -> Int? {
            views.firstIndex {
                $0.id == identifier
            }
        }
    }
}

// the actual element in the stack
private struct ViewElement: Identifiable, Equatable {
    let id: String
    let screen: ScreenDefinition

    static func == (lhs: ViewElement, rhs: ViewElement) -> Bool {
        lhs.id == rhs.id
    }
}

public class NavigationStackModel: ObservableObject {
    @Published var dict: [String: NavigationStack] = [:]
    private var cancellables = [AnyCancellable]()
    
    func getStack(id: String) -> NavigationStack {
        if (self.dict[id] == nil) {
            let newStack = NavigationStack(easing: .default)
            self.dict[id] = newStack;
            // This does not happen by default for arrays.
            self.cancellables.append(newStack.objectWillChange.sink(receiveValue: { self.objectWillChange.send() }))
            return newStack;
        }
        
        return self.dict[id]!;
    }
}

struct NavigationStackView: View {
    @StateObject private var navViewModels: NavigationStackModel = NavigationStackModel()
    private let rootScreen: ScreenDefinition;

    public init(transitionType: NavigationTransition = .default, easing: Animation = .easeOut(duration: 0.2), rootView: ScreenDefinition) {
        self.rootScreen = rootView
    }

    public var body: some View {
        // Each type of root view (based on the root view id) can have their own stack. Essentially,
        // in react-navigation terms, we have a stack navigator, and each page within has their own
        // stack navigator.
        //
        // We do this because we want the root-level navigation to be drived by state, but within each
        // page, the user can navigate imperatively.
        //
        // We want this to update if NavigationStackView changes, or if the root changes.
        let currentStack = self.navViewModels.getStack(id: rootScreen.id)
        
        var currentScreen: ScreenDefinition;
        currentScreen = currentStack.currentView?.screen ?? rootScreen;
                
        return ZStack {
            BackgroundSimple(color: currentScreen.backgroundColor, rightColor: currentScreen.righthandColor)
                .transition(NavigationTransition.defaultTransitions.push)
                .id(currentScreen.id + "_bg")
            currentScreen.screen
                .id(currentScreen.id + "_controls")
                .transition(AnyTransition.opacity)
                .environmentObject(currentStack)
        }
    }
}
