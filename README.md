client# How the App Should Work
## Front End
* When a user visits the page, they should see a page title. They can either register or log in.
* Once logged in, the user should see a new game button.
* When the user clicks on the button, they should see a group of options and the start game button. Currently, available options are number of questions, 1 - 10.
* When the user clicks the new game button, the game screen should appear.
* The game screen should have the following:
  * The question number and the total questions, e.g. "Question 5/10"
  * A box containing 5 PlayingCards, representing the current board
  * An empty box with space for two PlayingCards. This space will hold the user's choice
  * A box containing 52 PlayingCards, representing all of the possible choices. PlayingCards that are in the box of the current board will be disabled.
    * When a user clicks on an active PlayingCard in the choices section, it will appear in the user's choice box. Clicking on the selected card again will remove it from the user choice box.
    * Clicking on a disabled card or a card when there are two cards in the user choice box will have no effect.
    * A user can click on a card in the user choice box to remove it.
  * There should be a submit answer button. It should be disabled unless two PlayingCards are in the user choice box.
  * There should be a clear answer button.
* When the user submits their answer choice, a message should appear within the game screen to tell the user whether they were right or display a correct answer if they were wrong. 
* Then, the game screen should display the next question if it is not the last question. Otherwise, it should display a game over screen, score, and a view detailed results button, a play again button, and a quit button.

## Back End
* When the start game button is clicked, a Game instance should be created in the database.
* When a question is displayed in the game, a Question instance should be created, then the Nut Finding Algorithm should determine the answer.
* When the submit answer button is clicked, the question should be updated with the user's answer. Then an Answer Checking Algorithm should run and determine whether the answer is right or wrong
* Clicking on view detailed results should get all of the questions associated with that game.#   n e w - n u t f i n d e r - f u l l s t a c k  
 