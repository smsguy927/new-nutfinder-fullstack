import React, { Component } from 'react';

import { Link, withRouter } from 'react-router-dom';

class ForgotPassword extends Component {

  state = {
    email: ""
  }

  resetMessage1 = "An email has been sent to"
  resetMessage2 = "Don't forget to check your spam folder!"
  handleChange = (event) => {
    const { name, value } = event.target
    this.setState({
      [name]: value
    })
  }

  handleSubmit = (event) => {
    event.preventDefault()
    fetch("/forgot_password", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
       email: this.state.email
      }),
    }).then((r) => {
      if (r.ok) {
        r.json()
          .then(() => alert(`${this.resetMessage1} ${this.state.email}. ${this.resetMessage2}`))
          .then(() => this.setState({ email: ""}))
      } else {
        r.json().then((err) => alert(err.error));
      }
    });

    this.props.history.push('/')//
  }

  render() {
    return (
      <>
      <p>Request password reset:</p>
    <form onSubmit={this.handleSubmit}>
      <input required id="forgotpasswordemail" onChange={this.handleChange} name="email" placeholder="email" type="email" value={this.state.email}/>
      <button >Submit</button>
    </form>
      </>
  );
  }
}

export default withRouter(ForgotPassword);