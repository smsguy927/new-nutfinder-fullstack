import React, { useState } from "react";


const RANKS = ['2','3','4','5','6','7','8','9','T','J','Q','K','A']
const SUITS = ['d', 'c', 'h', 's']
const NUM_RANKS = 13
const NUM_SUITS = 4
const CARD_SEP = '_'
const COMBO_SEP = '__'

function QuestionsContainer({ user, game, questions }) {



  const [errors, setErrors] = useState([]);
  const [isLoading, setIsLoading] = useState(false);


  return (
    <>
      <div>
        {questions?.map(q => <div><span>Question {q.question_num} |</span>
          <span> Board: {q.cards?.replaceAll(CARD_SEP, ' ')} |</span>
          <span>  You Chose: {q.user_choice?.replace(CARD_SEP, ' ')} |</span>
          <span>  Correct Answer: {q.answer?.replaceAll(COMBO_SEP, ', ').replaceAll(CARD_SEP, ' ')} |</span>
          <span>{q.is_right ? ' Right' : ' Wrong'}</span></div>)}
      </div>
    </>
  );
}



export default QuestionsContainer;