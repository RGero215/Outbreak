module.exports = async function(req, res) {
    const positives = await User.find({
        isPositive: true
    })
    res.send(positives)
}