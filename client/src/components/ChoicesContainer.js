import { useState } from "react";


const RANKS = ['2','3','4','5','6','7','8','9','T','J','Q','K','A']
const SUITS = ['d', 'c', 'h', 's']
const NUM_RANKS = 13
const NUM_SUITS = 4

function ChoicesContainer({ user, game }) {
    const [boardCards, setBoardCards] = useState([]);
    const [userChoice, setUserChoice] = useState([]);
    const [choices, setChoices] = useState([]);
    const [errors, setErrors] = useState([]);
    const [isLoading, setIsLoading] = useState(false);



    function calcID(suitI, rankI) {
        return suitI * NUM_RANKS + rankI + 1;
    }

    return (
        <>

        </>
    );
}



export default ChoicesContainer;