module.exports = async function(req, res) {
    console.log('User id is not positive: ' + req.param('id'))

    
    const user = await User.findOne({id: req.param('id')})
    
    if(req.session.userId === user.id){
        await User.updateOne({ id:  user.id})
            .set({
                isPositive: false 
            });
    }
    res.end()
}