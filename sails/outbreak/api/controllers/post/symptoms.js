module.exports = async function(req, res) {
    const symptoms = await User.find({
        hasSymptoms: true
    })
    res.send(symptoms)
}