import React, { useEffect, useState } from "react";
import { Switch, Route } from "react-router-dom";
import {useHistory} from "react-router";
import QuestionsContainer from "../components/QuestionsContainer";

function PastGames({user}) {
  const [games, setGames] = useState([])
  const [questions, setQuestions] = useState({})
  const [questionBtnStates, setQuestionBtnStates] = useState({})
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState([])
  const history = useHistory();

  const NO_ID = -1
  const QUESTION_BUTTON_OFF = 'Show Questions'
  const QUESTION_BUTTON_ON = 'Hide Questions'


  function setAllQuestionStates(id = NO_ID, foundQuestions = []) {

    //alert('z')
    let newQuestions = {...questions}
    if(id === NO_ID || !Object.keys(questions).length) {
      //alert('x')
      games.forEach(g => {newQuestions[g.id] = []})
    } else {
      newQuestions[id] = foundQuestions
    }
    setQuestions(newQuestions)
  }

  function setAllQuestionBtnStates(id = NO_ID) {

    let newQuestionBtnStates = {...questionBtnStates}
    if(id === NO_ID || !Object.keys(questionBtnStates).length) {
      games.forEach(g => {newQuestionBtnStates[g.id] = QUESTION_BUTTON_OFF})
      setAllQuestionStates()
    } else {
      if (newQuestionBtnStates[id] === QUESTION_BUTTON_ON) {
        newQuestionBtnStates[id] = QUESTION_BUTTON_OFF
      } else {
        newQuestionBtnStates[id] = QUESTION_BUTTON_ON
      }
    }
    setQuestionBtnStates(newQuestionBtnStates)


  }

  async function getPastGames() {
    fetch(`http://localhost:3000/games/${user.id}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      }
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json().then((games) => setGames(games))
      } else {
        r.json().then((err) => setErrors(err.errors));
      }
    });
  }

  useEffect(async() => {
    await getPastGames()
    await setAllQuestionBtnStates()
    await setAllQuestionStates()

  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  function getQuestions(currentId) {
    fetch(`http://localhost:3000/questions/${currentId}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      }
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json().then((newQuestions) => setAllQuestionStates(currentId, newQuestions))
      } else {
        r.json().then((err) => setErrors(err.errors));
      }
    });
  }

  function handleShowQuestionsClick(e) {
    let currentId = parseInt(e.target.id)
    setAllQuestionBtnStates(currentId)
    if(questions[currentId]?.length === 0) {
      getQuestions(currentId)
    }
  }

  return (
    <>
      {isLoading && <h2>Loading...</h2>}
      <h2>My Past Games</h2>
      {games.map(g => {
        return <div>
          Game {g.id} | Questions: {g.num_questions} | Correct: {g.num_right}{' '} |
          Score: {g.score} |
          <button id={`${g.id}questions`} onClick={handleShowQuestionsClick}>{questionBtnStates[g.id] ?? 'Click to' +
          ' load questions'}</button>
          {questionBtnStates[g.id] === QUESTION_BUTTON_ON && <QuestionsContainer questions={questions[g.id]} /> }
        </div>
      })}

      <button onClick={() => history.push('/')}>Go Back</button>
    </>
  )


}



export default PastGames;