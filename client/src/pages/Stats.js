import React, { useEffect, useState } from "react";
import { Switch, Route } from "react-router-dom";
import {useHistory} from "react-router";




function Stats({user}) {
  const [games, setGames] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState([])
  const history = useHistory();

  async function getPastGames() {
    fetch(`http://localhost:3000/games/${user.id}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      }
    }).then((r) => {
      setIsLoading(false);
      if (r.ok) {
        r.json().then((games) => setGames(games));
      } else {
        r.json().then((err) => setErrors(err.errors));
      }
    });
  }

  useEffect(async() => {
    await getPastGames()

  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const toNumQuestions = games => games.map(g => g.num_questions );

  function getTotalQuestions() {
    const questionReducer = (total, game) => game.num_questions + total;
    return games.reduce(questionReducer, 0)
  }

  function getTotalCorrectAnswers() {
    const correctReducer = (total, game) => game.num_right + total;
    return games.reduce(correctReducer, 0)
  }

  function getLongestGame() {
    return Math.max(...toNumQuestions(games))
  }

  function getShortestGame() {
    return Math.min(...toNumQuestions(games))
  }

  function addSuffix(num) {
    return num === 1 ? `${num} question` : `${num} questions`
  }

  function getTotalPoints() {
    const pointsReducer = (total, game) => game.score + total;
    return games.reduce(pointsReducer, 0)
  }
  return (
    <>
      {isLoading && <h2>Loading...</h2>}
      <h2>My Stats</h2>
      <p>Total Games Played: {games.length}</p>
      <p>Total Questions Answered: {getTotalQuestions()}</p>
      <p>Total Correct Answers: {getTotalCorrectAnswers()}</p>
      <p>Longest Game: {addSuffix(getLongestGame())}</p>
      <p>Shortest Game: {addSuffix(getShortestGame())}</p>
      <p>Total Points: {getTotalPoints()}</p>
      <button onClick={() => history.push('/')}>Go Back</button>
    </>
  )

}

export default Stats;