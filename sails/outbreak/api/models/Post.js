module.exports = {

    customToJSON: function() {
        const fromNow = sails.moment(this.createdAt).fromNow()
        this.fromNow = fromNow
        return this
    },


    attributes: {
        text: {
            type: 'string', required: true
        },
        imageUrl: {
            type: 'string',
            defaultsTo: '',
        },
        user: {
            model: 'user'
        },
        numLikes: {
            type: 'number', defaultsTo: 0
        },
    }
}