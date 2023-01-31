const AccuCoin = artifacts.require("AccuCoin");
const Cryptopati = artifacts.require("Cryptopati");

module.exports = async function (deployer, network, accounts) {
    const cryptopati = await Cryptopati.deployed();
    const questionTypes = 3, questionCount = 12
    const multiplier = [2, 4, 6]
    let questionCounter = 1;

    for (let i = 0; i < questionTypes; i++) {
        for (let j = 0; j < questionCount; j++) {
            let questionId = questionCounter.toString()
            cryptopati.addQuestion(questionId, multiplier[i]);
            questionCounter++;
        }
    }

};
