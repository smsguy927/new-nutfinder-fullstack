import { useState } from "react";


const RANKS = ['2','3','4','5','6','7','8','9','T','J','Q','K','A']
const SUITS = ['d', 'c', 'h', 's']
const NUM_RANKS = 13
const NUM_SUITS = 4

function BoardCardContainer({ user, game, boardCards }) {



    const [errors, setErrors] = useState([]);
    const [isLoading, setIsLoading] = useState(false);



    function calcID(suitI, rankI) {
        return suitI * NUM_RANKS + rankI + 1;
    }

    function toCard(cardId) {
        cardId--
        let rank = cardId % NUM_RANKS
        let suit = Math.floor(cardId / NUM_RANKS)
        return `${RANKS[rank]}${SUITS[suit]} `
    }

    return (
        <>
            <div>Board Cards</div>
            <div id='board-card-container'>
                {boardCards?.map(card => <span>{toCard(card)}</span>)}
            </div>
        </>
    );
}



export default BoardCardContainer;