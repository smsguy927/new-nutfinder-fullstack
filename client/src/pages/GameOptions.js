import React, { useState } from "react";
import { Button, Error, Input, FormField, Label} from "../styles";

const DEFAULT_NUM_QUESTIONS = 10

function GameOptions({ user, onStartGame }) {
    const [numQuestions, setNumQuestions] = useState(DEFAULT_NUM_QUESTIONS);
    const [errors, setErrors] = useState([]);
    const [isLoading, setIsLoading] = useState(false);

    function handleSubmit(e) {
        e.preventDefault();
        setErrors([]);
        setIsLoading(true);

        fetch("http://localhost:3000/games", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                user_id: user.id,
                num_questions: numQuestions
            }),
        }).then((r) => {
            setIsLoading(false);
            if (r.ok) {
                r.json().then((user) => onStartGame(user));
            } else {
                r.json().then((err) => setErrors(err.errors));
            }
        });
    }

    return (
        <form onSubmit={handleSubmit}>
            <FormField>
                <Label htmlFor="numQuestions">How Many Questions</Label>
                <Input
                    type="number"
                    id="numQuestions"
                    autoComplete="off"
                    value={numQuestions}
                    onChange={(e) => setNumQuestions(e.target.value)}
                />
            </FormField>
            <FormField>
                <Button type="submit">{isLoading ? "Loading..." : "New Game"}</Button>
            </FormField>
            <FormField>
                {errors?.map((err) => (
                    <Error key={err}>{err}</Error>
                ))}
            </FormField>
        </form>
    );
}

export default GameOptions;