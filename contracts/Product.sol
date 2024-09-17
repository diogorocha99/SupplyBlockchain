// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {

    address public owner;
    address public producer;
    address public transporter;
    address public retailer;

    enum State { Created, Shipped, InTransit, Delivered }
    
    struct Product {
        bytes32 id;
        string name;
        string origin;
        string details;
        State state;
        string currentLocation;
        string[] locationHistory;  // Array de strings para histórico de localizações
    }

    mapping(bytes32 => Product) public products;

    event ProductCreated(bytes32 productId, string name, string origin, string details);
    event ProductStateUpdated(bytes32 productId, State state, string currentLocation);

    modifier onlyProducer() {
        require(msg.sender == producer, "Only producer can call this function.");
        _;
    }

    modifier onlyTransporter() {
        require(msg.sender == transporter, "Only transporter can call this function.");
        _;
    }

    modifier onlyRetailer() {
        require(msg.sender == retailer, "Only retailer can call this function.");
        _;
    }

    modifier onlyParticipant() {
        require(msg.sender == producer || msg.sender == transporter || msg.sender == retailer, "Only authorized participants can call this function.");
        _;
    }

    constructor(address _producer, address _transporter, address _retailer) {
        owner = msg.sender;
        producer = _producer;
        transporter = _transporter;
        retailer = _retailer;
    }

    function generateProductId(string memory _name, string memory _origin) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _origin));
    }

    function addProduct(string memory _name, string memory _origin, string memory _details) public onlyProducer {
        bytes32 productId = generateProductId(_name, _origin);

        products[productId] = Product({
            id: productId,
            name: _name,
            origin: _origin,
            details: _details,
            state: State.Created,
            currentLocation: "",
            locationHistory: getLocationHistory(productId)   // Inicializa como um array vazio
        });
        emit ProductCreated(productId, _name, _origin, _details);
    }

    function updateProductState(bytes32 _productId, State _state, string memory _location) public onlyParticipant {
        Product storage product = products[_productId];
        product.state = _state;
        product.currentLocation = _location;
        product.locationHistory.push(_location);  // Adiciona nova localização ao histórico
        emit ProductStateUpdated(_productId, _state, _location);
    }

    function getProduct(bytes32 _productId) public view returns (string memory name, string memory origin, string memory details, State state, string memory currentLocation, string[] memory locationHistory) {
        Product memory product = products[_productId];
        return (product.name, product.origin, product.details, product.state, product.currentLocation, product.locationHistory);
    }
    
    // Função para acessar o histórico de localizações de um produto
    function getLocationHistory(bytes32 _productId) public view returns (string[] memory) {
        return products[_productId].locationHistory;
    }

    // Função para alterar a localização atual de um produto (se necessário)
    function updateCurrentLocation(bytes32 _productId, string memory _newLocation) public onlyParticipant {
        products[_productId].currentLocation = _newLocation;
    }
}
