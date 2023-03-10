const Cryptopati = artifacts.require("Cryptopati");

module.exports = async function (deployer, network, accounts) {
    const cryptopati = await Cryptopati.deployed();

    let questionSetList = [
        { from: 1, to: 12, multiplier: 2 },
        { from: 13, to: 24, multiplier: 5 },
        { from: 25, to: 37, multiplier: 10 },
        { from: 38, to: 41, multiplier: 5 },
        { from: 42, to: 50, multiplier: 2 },
        { from: 51, to: 55, multiplier: 5 },
        { from: 56, to: 63, multiplier: 10 },

    ]

    await Promise.all(questionSetList.map(async ({ from, to, multiplier }) => {
        for (let questionCounter = from; questionCounter <= to; questionCounter++) {
            let questionId = questionCounter.toString()
            let questionAdded = await cryptopati.questionExist(questionId);
            if (!questionAdded) {
                console.log(`QuestionId : ${questionId}, Multiplier : ${multiplier}`)
                await cryptopati.addQuestion(questionId, multiplier);
            }
        }
    }))

};
