module.exports = async function(req, res) {
    console.log("Trying to update user")

    const fullName = req.body.fullName
    const bio = req.body.bio

    const file = req.file('imagefile')

    // no avatar file change was found
    if (file.isNoop) {
        await User.update({id: req.session.userId})
            .set({fullName: fullName, bio: bio})
        file.upload({noop: true})
        return res.end()
    }

    try {
        const fileUrl = await sails.helpers.uploadfile(file)
        const userId = req.session.userId
        const record = await User.update({id: userId})
            .set({fullName: fullName, bio: bio, profileImageUrl: fileUrl}).fetch()
    
        console.log(JSON.parse(JSON.stringify(record)))
        res.end()
    } catch (err) {
        res.serverError(err.toString())
    }
    
}