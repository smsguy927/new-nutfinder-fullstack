import React, { useEffect, useState } from "react";
import { Switch, Route, useParams } from "react-router-dom";
import NavBar from "./NavBar";
import Login from "../pages/Login";
import GameOptions from "../pages/GameOptions";
import Game from "../pages/Game";
import Home from "../pages/Home";
import ResetPassword from "./ResetPassword";
import PastGames from "../pages/PastGames";
import Stats from "../pages/Stats";




function App() {
  const [user, setUser] = useState(null);
  const [game, setGame] = useState(null);

  useEffect(() => {
    // auto-login
    fetch("/me").then((r) => {
      if (r.ok) {
        r.json().then((user) => setUser(user));
      }
    });
  }, []);

  if (!user) return <Login onLogin={setUser} />;
  if (game) return <Game user={user} game={game} setGame={setGame} onStartGame={handleStartGame} />;

  function handleStartGame(game) {
    setGame(game)
  }
  return (
    <>
      <NavBar user={user} setUser={setUser} />
      <main>
        <Switch>
          <Route path="/reset-password">
            <ResetPassword user={user}/>
          </Route>
          <Route path="/game">
            <Game user={user} />
          </Route>
          <Route path="/past-games">
            <PastGames user={user} />
          </Route>
          <Route path="/stats">
            <Stats user={user} />
          </Route>

          <Route path="/game-options">
            <GameOptions user={user} onStartGame={handleStartGame} />
          </Route>
          <Route exact path="/">
            <Home/>
          </Route>
        </Switch>
      </main>
    </>
  );
}

export default App;
