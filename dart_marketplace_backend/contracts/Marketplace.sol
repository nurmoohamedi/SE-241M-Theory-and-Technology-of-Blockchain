// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.9.0;

contract Marketplace {
    struct Item {
        uint256 id;
        address payable seller;
        string name;
        string description;
        uint256 price;
        bool sold;
    }

    struct Review {
        address reviewer;
        uint256 rating;
        string comment;
    }

    mapping(uint256 => Item) public items;
    mapping(uint256 => Review[]) public itemReviews;
    uint256 public itemCount;

    event ItemListed(
        uint256 indexed id,
        address seller,
        string name,
        uint256 price
    );
    event ItemSold(
        uint256 indexed id,
        address buyer,
        address seller,
        uint256 price
    );
    event ReviewAdded(uint256 indexed id, address reviewer, uint256 rating);

    function listItem(
        string memory _name,
        string memory _description,
        uint256 _price
    ) public {
        require(_price > 0, "Price must be greater than zero");

        itemCount++;
        items[itemCount] = Item(
            itemCount,
            payable(msg.sender),
            _name,
            _description,
            _price,
            false
        );

        emit ItemListed(itemCount, msg.sender, _name, _price);
    }

    function purchaseItem(uint256 _id) public payable {
        Item storage item = items[_id];
        require(_id > 0 && _id <= itemCount, "Item does not exist");
        require(!item.sold, "Item already sold");
        require(msg.value >= item.price, "Insufficient funds sent");

        item.sold = true;
        item.seller.transfer(item.price);

        if (msg.value > item.price) {
            payable(msg.sender).transfer(msg.value - item.price);
        }

        emit ItemSold(_id, msg.sender, item.seller, item.price);
    }

    function addReview(
        uint256 _id,
        uint256 _rating,
        string memory _comment
    ) public {
        require(_id > 0 && _id <= itemCount, "Item does not exist");
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");

        itemReviews[_id].push(Review(msg.sender, _rating, _comment));

        emit ReviewAdded(_id, msg.sender, _rating);
    }

    function getItem(uint256 _id) public view returns (Item memory) {
        require(_id > 0 && _id <= itemCount, "Item does not exist");
        return items[_id];
    }

    function getReviews(uint256 _id) public view returns (Review[] memory) {
        require(_id > 0 && _id <= itemCount, "Item does not exist");
        return itemReviews[_id];
    }
}
