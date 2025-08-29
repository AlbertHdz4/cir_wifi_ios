import UIKit

class CustomDialogViewController: UIViewController {
    
    // MARK: - Propiedad para el texto dinámico
    var textToShow: String?
    
    // MARK: - Vistas internas
    private let containerView = UIView()
    private let scrollView = UIScrollView()
    private let textLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        // Fondo semi-transparente para la apariencia de diálogo
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // =============== 1. CONTAINER VIEW ===============
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        // =============== 2. SCROLL VIEW ===============
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            // Dejamos espacio para el botón "Cerrar"
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60)
        ])
        
        // =============== 3. LABEL ===============
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = .black
        // Asignamos el texto dinámico (si es nil, mostramos un texto genérico)
        textLabel.text = textToShow ?? "No hay texto disponible."
        
        scrollView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // El ancho del label coincide con el ancho interno del scroll para permitir scroll vertical
            textLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // =============== 4. BOTÓN CERRAR ===============
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeDialog), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc private func closeDialog() {
        dismiss(animated: true, completion: nil)
    }
}
