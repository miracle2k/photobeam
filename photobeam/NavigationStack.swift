//
//  NavigationStack.swift
//
//  Created by Matteo Puccinelli on 28/11/2019.
//
// From https://github.com/biobeats/swiftui-navigation-stack/blob/master/Sources/NavigationStack/NavigationStack.swift
// It's because our own custom animations are not possible with the default NavigationController.
//

import SwiftUI

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
    public func push<Element: View>(_ element: Element, withId identifier: String? = nil) {
        withAnimation(easing) {
            navigationType = .push
            viewStack.push(ViewElement(id: identifier == nil ? UUID().uuidString : identifier!,
                                       wrappedElement: AnyView(element)))
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

    //the actual stack
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
    let wrappedElement: AnyView

    static func == (lhs: ViewElement, rhs: ViewElement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Views
/// An alternative SwiftUI NavigationView implementing classic stack-based navigation giving also some more control on animations and programmatic navigation.
struct NavigationStackView: View {
    @ObservedObject private var navViewModel: NavigationStack
    private let rootViewID = "root"
    private let rootView: ScreenDefinition;
    private let transitions: (push: AnyTransition, pop: AnyTransition)

    /// Creates a NavigationStackView.
    /// - Parameters:
    ///   - transitionType: The type of transition to apply between views in every push and pop operation.
    ///   - easing: The easing function to apply to every push and pop operation.
    ///   - rootView: The very first view in the NavigationStack.
    public init(transitionType: NavigationTransition = .default, easing: Animation = .easeOut(duration: 0.2), rootView: ScreenDefinition) {
        self.rootView = rootView
        self.navViewModel = NavigationStack(easing: easing)
//        switch transitionType {
//        case .none:
//            self.transitions = (.identity, .identity)
//        case .custom(let trans):
//            self.transitions = (trans, trans)
//        default:
//            self.transitions = NavigationTransition.defaultTransitions
//        }
        self.transitions = (.scale, .scale)
    }

    public var body: some View {
        let showRoot = navViewModel.currentView == nil
        let navigationType = navViewModel.navigationType
        
        var currentView: AnyView;
        var currentViewId: String;
        var currentColor: Color;
        var rightColor: Color;
        
        if showRoot {
            currentView = rootView.screen
            currentViewId = rootViewID;
            currentColor = rootView.backgroundColor;
            rightColor = rootView.righthandColor;
        } else {
            currentView = navViewModel.currentView!.wrappedElement;
            currentViewId = navViewModel.currentView!.id;
            currentColor = Color.red;
            rightColor = Color.blue;
        }
        
        return ZStack {
            BackgroundSimple(color: currentColor, rightColor: rightColor)
                .transition(NavigationTransition.defaultTransitions.push)
                .id(currentViewId)
            currentView
                .id(currentViewId + "_controls")
                .transition(AnyTransition.opacity)
                .environmentObject(navViewModel)
        }
    }
}

struct ScreenDefinition {
    var backgroundColor: Color
    var righthandColor: Color
    var screen: AnyView
}
