pragma solidity ^0.8.10;

interface IERC721
    {
        function safeTranFrom(address from, address to, uint tokenId) external;
        function transferFrom(address,address,uint) external;
    }

    contract EnglishAuction
        {   // events for console information, what is going on......
            event Start();
            event Bid(address indexed sender,uint amount);
            event Withdraw(address indexed bidder,uint amount);
            event End(address winner,uint amount);

            //for declaration of item as "nft" which is going to be auctioned
 
            IERC721 public nft; // IERC721 => address
            uint public nftId;

            //declaration of variables who is participating...

            address payable public seller;
            uint public endAt;
            bool public started;
            bool public ended;

            address public highestBidder;
            uint public highestBid;

            mapping(address => uint) public bids;

            constructor(address _nft, uint _nftId,uint _startingBid)
                {
                    nft = IERC721(_nft);
                    nftId = _nftId;

                    seller = payable(msg.sender);
                    highestBid = _startingBid;
                }


                function start() external
                    {   require(msg.sender == seller,"not seller");
                       // require( !started,"Started");
                                                                     
                        started = true;
                        endAt = block.timestamp + 7 days;
                       nft.transferFrom(msg.sender,address(this),nftId);

                        emit Start();
                    }

                function bid() external payable
                    {
                        require(started,"not started");
                        require(block.timestamp<endAt,"ended");
                        require(msg.value>highestBid,"value<highestBId");

                        if (highestBidder != address(0))
                            {
                                bids[highestBidder]+=highestBid;
                                highestBid=msg.value;
                                highestBidder = msg.sender;

                                emit Bid(msg.sender,msg.value);

                            }


                    }
                function withdraw() external
                    {
                        uint bal = bids[msg.sender];
                        bids[msg.sender] = 0;
                        payable (msg.sender).transfer(bal);

                        emit Withdraw(msg.sender,bal);

                        
                    }
                function end() external
                    {
                        require(started,"not started");
                        require(block.timestamp >= endAt,"not Ended");
                        require(!ended,"ended");
                        ended = true;



                        if(highestBidder != address(0))
                            {
                                nft.safeTranFrom(address(this),highestBidder,nftId);
                                seller.transfer(highestBid);
                            }
                        else
                            {
                                 nft.safeTranFrom(address(this),seller,nftId);
                            }
                            emit End(highestBidder,highestBid);                                                                 
                    }
        }