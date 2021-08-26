import { useState } from "react";
import styled from "styled-components";
import LoginForm from "../components/LoginForm";
import SignUpForm from "../components/SignUpForm";
import { Button } from "../styles";
import ForgotPassword from "../components/ForgotPassword";

function Login({ onLogin }) {
  const [showLogin, setShowLogin] = useState(true);
  const [showSendAc, setShowSendAc] = useState(false);

  return (
    <Wrapper>
      <Logo>Nutfinder Training</Logo>
      {showLogin ? (
        <>
          <LoginForm onLogin={onLogin} />
          <Divider />
          <p>

            <Button color="secondary" onClick={() => setShowLogin(false)}>
              Sign Up
            </Button>
            <Button color="secondary" onClick={() => setShowSendAc(!showSendAc)}>
              I Forgot My Password
            </Button>
          </p>
        </>
      ) : (
        <>
          <SignUpForm onLogin={onLogin} />
          <Divider />
          <p>
            Already have an account? &nbsp;
            <Button color="secondary" onClick={() => setShowLogin(true)}>
              Log In
            </Button>

          </p>
        </>
      )}
      {showSendAc &&  <ForgotPassword/>}
    </Wrapper>
  );
}

const Logo = styled.h1`
  font-family: "Permanent Marker", cursive;
  font-size: 3rem;
  color: #123456;
  margin: 8px 0 16px;
`;

const Wrapper = styled.section`
  max-width: 500px;
  margin: 40px auto;
  padding: 16px;
`;

const Divider = styled.hr`
  border: none;
  border-bottom: 1px solid #ccc;
  margin: 16px 0;
`;

export default Login;
