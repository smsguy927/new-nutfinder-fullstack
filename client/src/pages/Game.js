import React, {useState, useEffect} from "react";
import {Route, useHistory} from "react-router";
import { Link } from "react-router-dom";
import styled from "styled-components";
import BoardCardContainer from "../components/BoardCardContainer";
import UserChoiceContainer from "../components/UserChoiceContainer";
import GameOptions from "./GameOptions";


const RANKS = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
const SUITS = ['d', 'c', 'h', 's']
const NUM_RANKS = 13
const NUM_SUITS = 4
const NUM_BOARD_CARDS = 5
const NUM_USER_CHOICE = 2
const DECK_SIZE = 52
const CARD_SEP = '_'
const COMBO_SEP = '__'

function Game({user, game, setGame, onStartGame}) {
  const [questionNum, setQuestionNum] = useState(1)
  const [question, setQuestion] = useState(null)
  const [gameOver, setGameOver] = useState(false)
  const [boardCards, setBoardCards] = useState([]);
  const [userChoice, setUserChoice] = useState([]);
  const [numRight, setNumRight] = useState(0);
  const [results, setResults] = useState([])
  const [choices, setChoices] = useState([]);
  const [errors, setErrors] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const history = useHistory();






  useEffect(async() => {
    if (user && questionNum <= game.num_questions) {
      await selectBoardCards()
      createBoardCards()
    }
  }, [questionNum]); // eslint-disable-line react-hooks/exhaustive-deps

  function createBoardCards() {
    boardCards.forEach(card => createBoardCard(card))
  }

  function createBoardCard(card) {

    fetch("http://localhost:3000/board_cards", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        question_id: question.id,
        card_id: card
      }),
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json().then();
      } else {
        r.json().then((err) => setErrors([...errors,err.errors]));
      }
    });
  }

  function createQuestion(arr) {


    let boardCardStr = arr.map(bc => toCard(bc)).join(CARD_SEP)
    if(arr.length === NUM_BOARD_CARDS) {


      fetch("http://localhost:3000/questions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          game_id: game.id,
          question_num: questionNum,
          cards: boardCardStr
        }),
      }).then((r) => {
        setIsLoading(false);
        if (r.ok) {
          r.json().then(question => setQuestion(question));
        } else {
          r.json().then((err) => setErrors([...errors, err.errors]));
        }
      });
    }
  }

  async function selectBoardCards() {
    let boardCardArr = []
    while (boardCardArr.length < NUM_BOARD_CARDS) {
      let cardId = getRandomCardId()
      if (!boardCardArr.includes(cardId))
        boardCardArr.push(cardId)
    }

    setBoardCards(boardCardArr)
    createQuestion(boardCardArr)
    return boardCardArr
  }


  function getRandomCardId() {
    return Math.floor(Math.random() * DECK_SIZE) + 1
  }

  function getCardOnBoardError(e) {
    return `You cannot select the ${e.target.innerText}. It is already on the board`
  }


  function calcID(suitI, rankI) {
    return suitI * NUM_RANKS + rankI + 1;
  }

  function toCard(cardId) {
    cardId--
    let rank = cardId % NUM_RANKS
    let suit = Math.floor(cardId / NUM_RANKS)
    return `${RANKS[rank]}${SUITS[suit]}`
  }


  function handleClearAnswerClick() {
    clearUserChoice()
  }

  function setResultsAndNumRight(message) {
    setResults([...results,message])
    setNumRight(results.filter(r => r.is_right).length)
  }

  function handleGameOver() {
    setGameOver(true)

    fetch(`http://localhost:3000/games/${game.id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        id: game.id,
      }),
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json().then()
      } else {
        r.json().then((err) => setErrors([...errors,err.errors]));
      }
    });
  }

  function clearUserChoice() {
    setUserChoice([])
  }

  function updateQuestionWithUserChoice() {

    let qId = question.id
    let cardString = userChoice.map(choice => toCard(choice)).join(CARD_SEP)
    fetch(`http://localhost:3000/questions/${qId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        id: qId,
        user_choice: cardString
      }),
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json()
          .then(message => setResultsAndNumRight(message))
      } else {
        r.json().then((err) => setErrors([...errors,err.errors]));
      }
    });
  }

  function handleSubmitAnswerClick() {
    if (userChoice.length < NUM_USER_CHOICE || gameOver) {

    } else {
      updateQuestionWithUserChoice()
      clearUserChoice()
      setQuestionNum(questionNum + 1)
      questionNum >= game.num_questions && handleGameOver()
    }
  }

  function getCardSelectedError(e) {
    return `You cannot select the ${e.target.innerText}. You already selected it. Press Clear Answer to deselect it.`
  }

  function getTooManySelectedCardsError(e) {
    return `You cannot select the ${e.target.innerText}. Your answer contains enough cards. 
    Press Clear Answer to clear your selections.`
  }

  function handleChoicesCardClick(e) {
    let cardId = parseInt(e.target.id)

    if(!userChoice.includes(cardId) && !boardCards.includes(cardId) && userChoice.length < NUM_USER_CHOICE) {
      setUserChoice([...userChoice, parseInt(cardId)])
      setErrors([])
    }else if (boardCards.includes(cardId)) {
      setErrors([getCardOnBoardError(e)])
    } else if (userChoice.includes(cardId)) {
      setErrors([getCardSelectedError(e)])
    } else {
      setErrors([getTooManySelectedCardsError(e)])
    }

  }

  return (
    <>
      {!gameOver ? <div>Question {questionNum} of {game.num_questions}</div> : <div>Game Over</div>}
      <BoardCardContainer boardCards={boardCards}/>
      <UserChoiceContainer userChoice={userChoice}/>
      <div>Choices</div>
      <div id='choices-container'>
    {SUITS.map((suit, suitI) => (
      RANKS.map((rank, rankI) => (
      <>
      <button key={calcID(suitI, rankI)} id={calcID(suitI, rankI)}
      onClick={handleChoicesCardClick}>{rank}{suit}</button>
    {rankI === NUM_RANKS - 1 && <br/>}
      </>
      ))
      ))}
      </div>

      <button onClick={handleClearAnswerClick}>Clear Answer</button>
      <button onClick={handleSubmitAnswerClick}>Submit Answer</button>
      <div id='results-container'>
        <div>
          {results.map(result => <div><span>Question {result.question_num}</span>
            <span> Board: {result.cards.replaceAll(CARD_SEP, ' ')}</span>
            <span>  You Chose: {result.user_choice.replace(CARD_SEP, ' ')}</span>
            <span>  Correct Answer: {result.answer.replaceAll(COMBO_SEP, ', ').replaceAll(CARD_SEP, ' ')}</span>
            <span>{result.is_right ? ' Right' : ' Wrong'}</span></div>)}
        </div>
      </div>
      <div id='errors-container'>
        {errors?.map(error => <div>{error}</div>)}
      </div>
      {gameOver && <div>Game Over. Thanks For Playing <button onClick={() => setGame(null)}>Home</button></div>}
      {/*<div>Game Over. Thanks For Playing</div>*/}
    </>
  );
}

const Wrapper = styled.section`
  max-width: 1000px;
  margin: 40px auto;
  padding: 16px;
  display: flex;
  gap: 24px;
`;


const WrapperChild = styled.div`
  flex: 1;
`;

export default Game;