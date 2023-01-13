//SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.5.0 < 0.9.0;

contract Ecommerce {
    struct Product {
        string title;
        string desc;
        address payable seller;
        uint256 productId;
        uint256 price;
        address buyer;
        bool delivered;
    }
    address payable  public manager;
    bool destroyed = false;

    constructor() {
        manager = payable(msg.sender);
    }

    uint256 counter = 1;
    Product[] public products;

    modifier isNotDestroyed() {
        require(!destroyed, "Contract does not exist");
        _;
    }

    function registerProduct(
        string memory _title,
        string memory _desc,
        uint256 _price
    ) public isNotDestroyed {
        require(_price > 0, "Price should be greater than zero");
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10**18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;
    }

    function buy(uint256 _productId) public payable isNotDestroyed {
        require(
            products[_productId - 1].price == msg.value,
            "Pay the exact price"
        );
        require(
            products[_productId - 1].seller != msg.sender,
            "Seller cannot buy"
        );
        products[_productId - 1].buyer = msg.sender;
    }

    function delivery(uint256 _productId) public isNotDestroyed {
        require(
            products[_productId - 1].buyer == msg.sender,
            "Only buyer can confirm"
        );
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(
            products[_productId - 1].price
        );
    }

    // function destroy() public{ // require(manager==msg.sender,"Only manager can call this function"); // selfdestruct(manager); //Not the right way to destroy the contract // }

    function destroy() public isNotDestroyed {
        require(manager == msg.sender, "only manager can call this");
        manager.transfer(address(this).balance);
        destroyed = true;
    }

    fallback() external payable {
        payable(msg.sender).transfer(msg.value);
    }
}
