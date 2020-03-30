module.exports = async function(req, res) {
    console.log('User id has no symptoms: ' + req.param('id'))

    
    const user = await User.findOne({id: req.param('id')})
    
    if(req.session.userId === user.id){
        await User.updateOne({ id:  user.id})
            .set({
                hasSymptoms: false 
            });
    }

    res.end()
}