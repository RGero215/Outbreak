module.exports = async function(req, res) {
    console.log('Listing out all users:')
    
    // fetch all users 
    const users = await User.find({})

    res.send(users)
}