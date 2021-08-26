import React, { useState } from "react";
import { Button, Error, Input, FormField, Label} from "../styles";
import {useHistory} from "react-router";

function ResetPassword({ user }) {

  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [errors, setErrors] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const history = useHistory();

  function handleSubmit(e) {
    e.preventDefault();
    setErrors([]);
    setIsLoading(true);

    if (password === passwordConfirmation) {
      fetch(`/users/${user.id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          id: user.id,
          password: password,
          password_confirmation: passwordConfirmation,

        }),
      }).then((r) => {
        setIsLoading(false);
        if (r.ok) {
          r.json().then(() => alert('Password reset successful.'));
        } else {
          r.json().then((err) => setErrors(err.errors));
        }
      });
      history.push('/')
    } else {
      setPassword("")
      setPasswordConfirmation("")
      alert('Passwords do not match!')
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <FormField>
        <Label htmlFor="password">Password</Label>
        <Input
          type="password"
          id="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoComplete="current-password"
        />
      </FormField>
      <FormField>
        <Label htmlFor="password">Password Confirmation</Label>
        <Input
          type="password"
          id="password_confirmation"
          value={passwordConfirmation}
          onChange={(e) => setPasswordConfirmation(e.target.value)}
          autoComplete="current-password"
        />
      </FormField>



      <FormField>
        <Button type="submit">{isLoading ? "Loading..." : "Reset Password"}</Button>
      </FormField>
      <FormField>
        {errors?.map((err) => (
          <Error key={err}>{err}</Error>
        ))}
      </FormField>
    </form>
  );
}

export default ResetPassword;
