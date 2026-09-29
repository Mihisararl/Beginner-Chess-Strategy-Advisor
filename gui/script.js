let config = null;

let questions = [];

let followups = [];

let currentQuestionIndex = 0;

let answers = {};


// ============================================================
// DOM ELEMENTS
// ============================================================

const welcomeScreen =
    document.getElementById(
        "welcome-screen"
    );

const questionScreen =
    document.getElementById(
        "question-screen"
    );

const analyzingScreen =
    document.getElementById(
        "analyzing-screen"
    );

const resultScreen =
    document.getElementById(
        "result-screen"
    );


// ============================================================
// LOAD CONFIGURATION FROM PROLOG
// ============================================================

async function loadConfiguration() {

    try {

        const response =
            await fetch("/config");


        const result =
            await response.json();


        if (!result.success) {

            throw new Error(
                result.error
            );
        }


        config =
            result.data;


        questions =
            config.questions;


        followups =
            config.followups;


        initializeApplication();


    } catch (error) {

        console.error(error);

        showSystemError(
            error.message
        );
    }
}


// ============================================================
// INITIALIZE APPLICATION
// ============================================================

function initializeApplication() {

    const ui =
        config.application;


    document.title =
        ui.title;


    document.getElementById(
        "header-title"
    ).textContent =
        ui.title;


    document.getElementById(
        "header-status"
    ).textContent =
        ui.status;


    document.getElementById(
        "welcome-title"
    ).textContent =
        ui.welcomeTitle;


    document.getElementById(
        "welcome-description"
    ).textContent =
        ui.welcomeDescription;


    document.getElementById(
        "start-button"
    ).textContent =
        ui.startButton;


    document.getElementById(
        "back-button"
    ).textContent =
        ui.backButton;


    document.getElementById(
        "continue-button"
    ).textContent =
        ui.continueButton;


    document.getElementById(
        "analyzing-title"
    ).textContent =
        ui.analyzingTitle;


    document.getElementById(
        "analyzing-description"
    ).textContent =
        ui.analyzingDescription;


    document.getElementById(
        "recommendation-label"
    ).textContent =
        ui.recommendationLabel;


    document.getElementById(
        "reasoning-heading"
    ).textContent =
        ui.reasoningHeading;


    document.getElementById(
        "summary-heading"
    ).textContent =
        ui.summaryHeading;


    document.getElementById(
        "view-answers-button"
    ).textContent =
        ui.viewAnswersButton;


    document.getElementById(
        "restart-button"
    ).textContent =
        ui.restartButton;


    document.getElementById(
        "footer-text"
    ).textContent =
        ui.footer;


    initializeAnswers();
}


// ============================================================
// INITIALIZE ANSWERS
// ============================================================

function initializeAnswers() {

    answers = {};


    questions.forEach(
        question => {

            answers[
                question.id
            ] = null;
        }
    );


    followups.forEach(
        followup => {

            answers[
                followup.id
            ] = null;
        }
    );
}


// ============================================================
// SCREEN CONTROL
// ============================================================

function showScreen(screen) {

    document
        .querySelectorAll(".screen")
        .forEach(
            item => {

                item.classList.remove(
                    "active"
                );
            }
        );


    screen.classList.add(
        "active"
    );
}


// ============================================================
// START
// ============================================================

document
    .getElementById("start-button")
    .addEventListener(
        "click",
        startSystem
    );


function startSystem() {

    currentQuestionIndex = 0;

    initializeAnswers();

    showQuestion();

    showScreen(
        questionScreen
    );
}


// ============================================================
// SHOW QUESTION
// ============================================================

function showQuestion() {

    const question =
        questions[
        currentQuestionIndex
        ];


    document.getElementById(
        "question-number"
    ).textContent =
        `${question.number} / ${questions.length}`;


    document.getElementById(
        "category-name"
    ).textContent =
        question.category;


    document.getElementById(
        "question-title"
    ).textContent =
        question.title;


    document.getElementById(
        "question-description"
    ).textContent =
        question.description;


    document.getElementById(
        "step-label"
    ).textContent =
        `${question.number} / ${questions.length}`;


    const percentage =
        Math.round(
            (
                question.number /
                questions.length
            ) * 100
        );


    document.getElementById(
        "step-percentage"
    ).textContent =
        `${percentage}%`;


    document.getElementById(
        "progress-fill"
    ).style.width =
        `${percentage}%`;


    renderOptions(
        question
    );


    renderFollowup();


    updateSelectedAnswer();


    updateNavigation();
}


// ============================================================
// RENDER MAIN OPTIONS
// ============================================================

function renderOptions(question) {

    const container =
        document.getElementById(
            "options-container"
        );


    container.innerHTML = "";


    question.options.forEach(
        (option, index) => {

            const card =
                document.createElement(
                    "button"
                );


            card.type = "button";


            card.className =
                "option-card";


            if (
                answers[
                question.id
                ] === option.value
            ) {

                card.classList.add(
                    "selected"
                );
            }


            card.innerHTML = `

                <span class="option-number">
                    ${index + 1}
                </span>

                <span class="option-content">

                    <span class="option-title">
                        ${option.title}
                    </span>

                    <span class="option-description">
                        ${option.description}
                    </span>

                </span>

                <span class="radio-indicator"></span>
            `;


            card.addEventListener(
                "click",
                () => {

                    answers[
                        question.id
                    ] =
                        option.value;


                    clearDependentAnswers(
                        question.id
                    );


                    renderOptions(
                        question
                    );


                    renderFollowup();


                    updateSelectedAnswer();


                    updateNavigation();
                }
            );


            container.appendChild(
                card
            );
        }
    );
}


// ============================================================
// CLEAR FOLLOW-UP ANSWERS
// ============================================================

function clearDependentAnswers(
    questionId
) {

    followups
        .filter(
            followup =>
                followup.parent ===
                questionId
        )
        .forEach(
            followup => {

                answers[
                    followup.id
                ] = null;
            }
        );
}


// ============================================================
// RENDER FOLLOW-UP
// ============================================================

function renderFollowup() {

    const container =
        document.getElementById(
            "followup-container"
        );


    const question =
        questions[
        currentQuestionIndex
        ];


    const followup =
        followups.find(
            item =>

                item.parent ===
                question.id &&

                item.parentValue ===
                answers[
                question.id
                ]
        );


    if (!followup) {

        container.classList.add(
            "hidden"
        );


        document.getElementById(
            "followup-options"
        ).innerHTML = "";


        return;
    }


    container.classList.remove(
        "hidden"
    );


    document.getElementById(
        "followup-question"
    ).textContent =
        followup.title;


    const optionsContainer =
        document.getElementById(
            "followup-options"
        );


    optionsContainer.innerHTML = "";


    followup.options.forEach(
        (option, index) => {

            const card =
                document.createElement(
                    "button"
                );


            card.type = "button";


            card.className =
                "option-card";


            if (
                answers[
                followup.id
                ] === option.value
            ) {

                card.classList.add(
                    "selected"
                );
            }


            card.innerHTML = `

                <span class="option-number">
                    ${index + 1}
                </span>

                <span class="option-content">

                    <span class="option-title">
                        ${option.title}
                    </span>

                    <span class="option-description">
                        ${option.description}
                    </span>

                </span>

                <span class="radio-indicator"></span>
            `;


            card.addEventListener(
                "click",
                () => {

                    answers[
                        followup.id
                    ] =
                        option.value;


                    renderFollowup();


                    updateSelectedAnswer();


                    updateNavigation();
                }
            );


            optionsContainer.appendChild(
                card
            );
        }
    );
}


// ============================================================
// SELECTED ANSWER
// ============================================================

function updateSelectedAnswer() {

    const box =
        document.getElementById(
            "selected-answer-box"
        );


    const text =
        document.getElementById(
            "selected-answer-text"
        );


    const question =
        questions[
        currentQuestionIndex
        ];


    const selectedValue =
        answers[
        question.id
        ];


    if (!selectedValue) {

        box.classList.add(
            "hidden"
        );

        return;
    }


    const selectedOption =
        question.options.find(
            option =>
                option.value ===
                selectedValue
        );


    let displayText =
        selectedOption
            ? selectedOption.title
            : selectedValue;


    const followup =
        followups.find(
            item =>
                item.parent ===
                question.id &&

                item.parentValue ===
                selectedValue
        );


    if (
        followup &&
        answers[
        followup.id
        ]
    ) {

        const followupOption =
            followup.options.find(
                option =>
                    option.value ===
                    answers[
                    followup.id
                    ]
            );


        if (followupOption) {

            displayText +=
                " • " +
                followup.title +
                ": " +
                followupOption.title;
        }
    }


    text.textContent =
        displayText;


    box.classList.remove(
        "hidden"
    );
}


// ============================================================
// CHECK QUESTION COMPLETION
// ============================================================

function isCurrentQuestionComplete() {

    const question =
        questions[
        currentQuestionIndex
        ];


    if (
        !answers[
        question.id
        ]
    ) {

        return false;
    }


    const followup =
        followups.find(
            item =>

                item.parent ===
                question.id &&

                item.parentValue ===
                answers[
                question.id
                ]
        );


    if (
        followup &&
        !answers[
        followup.id
        ]
    ) {

        return false;
    }


    return true;
}


// ============================================================
// NAVIGATION
// ============================================================

function updateNavigation() {

    const backButton =
        document.getElementById(
            "back-button"
        );


    const continueButton =
        document.getElementById(
            "continue-button"
        );


    const ui =
        config.application;


    backButton.disabled =
        currentQuestionIndex === 0;


    continueButton.disabled =
        !isCurrentQuestionComplete();


    continueButton.textContent =

        currentQuestionIndex ===
            questions.length - 1

            ? ui.analyzeButton

            : ui.continueButton;
}


// ============================================================
// BACK
// ============================================================

document
    .getElementById(
        "back-button"
    )
    .addEventListener(
        "click",
        previousQuestion
    );


function previousQuestion() {

    if (
        currentQuestionIndex <= 0
    ) {

        return;
    }


    currentQuestionIndex--;


    showQuestion();
}


// ============================================================
// CONTINUE
// ============================================================

document
    .getElementById(
        "continue-button"
    )
    .addEventListener(
        "click",
        nextQuestion
    );


function nextQuestion() {

    if (
        !isCurrentQuestionComplete()
    ) {

        return;
    }


    if (
        currentQuestionIndex <
        questions.length - 1
    ) {

        currentQuestionIndex++;

        showQuestion();

        return;
    }


    startExpertAnalysis();
}


// ============================================================
// SEND DATA TO PROLOG
// ============================================================

async function startExpertAnalysis() {

    showScreen(
        analyzingScreen
    );


    try {

        const response =
            await fetch(
                "/analyze",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(
                            answers
                        )
                }
            );


        const result =
            await response.json();


        if (
            !result.success
        ) {

            throw new Error(
                result.error
            );
        }


        displayResult(
            result
        );


        showScreen(
            resultScreen
        );


    } catch (error) {

        console.error(error);

        showScreen(
            questionScreen
        );

        showSystemError(
            error.message
        );
    }
}


// ============================================================
// DISPLAY RESULT
// ============================================================

function displayResult(
    result
) {

    document.getElementById(
        "recommendation-title"
    ).textContent =
        result.info.title;


    document.getElementById(
        "recommendation-description"
    ).textContent =
        result.info.description;


    displayReasoning(
        result.reasoning,
        result.rules
    );


    displaySummary(
        result.answers
    );
}


// ============================================================
// DISPLAY REASONING
// ============================================================

function displayReasoning(
    reasoning,
    rules
) {

    const container =
        document.getElementById(
            "reasoning-container"
        );


    container.innerHTML = "";


    reasoning.forEach(
        (reason, index) => {

            const item =
                document.createElement(
                    "div"
                );


            item.className =
                "reasoning-item";


            item.innerHTML = `

                <span class="reasoning-number">
                    ${index + 1}
                </span>

                <span class="reasoning-text">
                    ${reason}
                </span>
            `;


            container.appendChild(
                item
            );
        }
    );


    if (
        rules &&
        rules.length > 0
    ) {

        const ruleTitle =
            document.createElement(
                "div"
            );


        ruleTitle.className =
            "reasoning-item";


        ruleTitle.innerHTML = `

            <span class="reasoning-number">
                ${reasoning.length + 1}
            </span>

            <span class="reasoning-text">
                ${rules.join(" → ")}
            </span>
        `;


        container.appendChild(
            ruleTitle
        );
    }
}


// ============================================================
// DISPLAY SUMMARY
// ============================================================

function displaySummary(
    data
) {

    const container =
        document.getElementById(
            "summary-container"
        );


    container.innerHTML = "";


    questions.forEach(
        question => {

            const value =
                data[
                question.id
                ];


            const option =
                question.options.find(
                    item =>
                        item.value ===
                        value
                );


            const row =
                document.createElement(
                    "div"
                );


            row.className =
                "summary-row";


            row.innerHTML = `

                <span class="summary-label">
                    ${question.category}
                </span>

                <span class="summary-value">
                    ${option
                    ? option.title
                    : value
                }
                </span>
            `;


            container.appendChild(
                row
            );
        }
    );
}


// ============================================================
// VIEW ANSWERS
// ============================================================

document
    .getElementById(
        "view-answers-button"
    )
    .addEventListener(
        "click",
        () => {

            currentQuestionIndex = 0;

            showQuestion();

            showScreen(
                questionScreen
            );
        }
    );


// ============================================================
// RESTART
// ============================================================

document
    .getElementById(
        "restart-button"
    )
    .addEventListener(
        "click",
        restartSystem
    );


function restartSystem() {

    currentQuestionIndex = 0;

    initializeAnswers();

    showScreen(
        welcomeScreen
    );
}


// ============================================================
// ERROR
// ============================================================

function showSystemError(
    message
) {

    const ui =
        config &&
        config.application;


    document.body.innerHTML = `

        <div class="system-error">

            <div>

                <h2>
                    ${ui
            ? ui.errorTitle
            : "System Error"
        }
                </h2>

                <p>
                    ${message}
                </p>

            </div>

        </div>
    `;
}


// ============================================================
// INITIAL LOAD
// ============================================================

loadConfiguration();