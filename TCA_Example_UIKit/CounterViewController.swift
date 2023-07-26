//
//  CounterViewController.swift
//  TCA_Example_UIKit
//
//  Created by Wojciech Spaleniak on 26/07/2023.
//

import UIKit
import ComposableArchitecture
import Combine

// MARK: Counter
/// Typ który zawiera domenę i zachowanie funkcjonalności.
/// Musi być zgodny z `ReducerProtocol`.
struct Counter: ReducerProtocol {
    
    // STATE
    /// Struktura przechowuje aktualny stan funkcjonalności.
    struct State: Equatable {
        var count = 0
    }
    
    // ACTION
    /// Typ definiuje dostępne akcje w funkcjonalności.
    enum Action: Equatable {
        case decrement
        case increment
    }
    
    // REDUCER
    /// Metoda z protokołu `ReducerProtocol`.
    /// Metoda pozwala zdefiniować logikę działania funkcjonalności.
    /// Jeżeli dana akcja nie ma efektu to zwracamy `.none`.
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decrement: state.count -= 1
        case .increment: state.count += 1
        }
        return .none
    }
}

class CounterViewController: UIViewController {
    
    // MARK: UI
    // Count label
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "\(viewStore.count)"
        return label
    }()
    
    // Plus button
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 10.0
        button.addTarget(self,
                         action: #selector(plusButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    // Minus button
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 10.0
        button.addTarget(self,
                         action: #selector(minusButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: Properties
    let store: StoreOf<Counter>
    let viewStore: ViewStore<Counter.State, Counter.Action>
    private var cancellable: AnyCancellable?
    
    // MARK: Init
    init(store: StoreOf<Counter>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        addObservations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservations()
    }

    private func setupView() {
        view.backgroundColor = .systemGray
    }
    
    private func setupSubviews() {
        view.addSubview(countLabel)
        view.addSubview(plusButton)
        view.addSubview(minusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            plusButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 20),
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 50),
            plusButton.heightAnchor.constraint(equalToConstant: 50),
            
            minusButton.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 20),
            minusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 50),
            minusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Metoda dodaje obserwacje na stan funkcjonalności `Counter`.
    /// Stan jest publikowany przez `publisher` z `viewStore`.
    /// Po otrzymaniu najnowszej wartości uaktualniany jest tekst w `countLabel`.
    private func addObservations() {
        cancellable = viewStore.publisher.sink { [weak self] state in
            self?.countLabel.text = String(state.count)
        }
    }
    
    private func removeObservations() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    /// Metoda wywoływana gdy klikniemy w przycisk minus.
    @objc private func minusButtonTapped() {
        viewStore.send(.decrement)
    }
    
    /// Metoda wywoływana gdy klikniemy w przycisk plus.
    @objc private func plusButtonTapped() {
        viewStore.send(.increment)
    }
}
