require "bundler/setup"
require "rubygems"
require "cloudmunch_sdk"
require "slack_chatter"
require "date"
require "json"

class CloudmunchSlackChatterApp < AppAbstract

    def initializeApp()
        @thisFileName = "CloudmunchSlackChatterApp"

        json_input = getJSONArgs()
        @log_level = !json_input['log_level'].nil? ? json_input['log_level'] : "INFO"
        logCategoryArray = ["debug", "warning", "info", "error", "fatal"]
        if !logCategoryArray.include? (@log_level.downcase) then
            @log_level = "info"
        end
        logInit(@log_level)

        #@insightHelper = getInsightHelper()
       
        @userName = !json_input['username'].nil? ? json_input['username'] : exitWithMessage("error", "Username is not provided!")        
        @accessToken = !json_input['access_token'].nil? ? json_input['access_token'] : exitWithMessage("error", "Access token is not provided!")        
        @channelID = !json_input['channel_id'].nil? ? json_input['channel_id'] : exitWithMessage("error", "Channel ID is not provided!")
        @message = !json_input['message'].nil? ? json_input['message'] : exitWithMessage("error", "Message is not provided!")
        @message_type = !json_input['message_type'].nil? ? json_input['message_type'] : exitWithMessage("error", "Message type is not provided!") 
        @message_to = !json_input['message_to'].nil? ? json_input['message_to'] : exitWithMessage("error", "Message Receiver is not provided!")
        log("debug", "#{__method__.to_s} in  #{@thisFileName} is invoked.")
    end

    def isAccessTokenValid(clientObj)
        clientObj.auth.test.ok ? return true : return false
    end
    
    def isValidChannel(channelName)
        public_channels = @client.channels.list.channels.map { |c| c["name"] }
        private_channels = @client.groups.list.groups.map { |g| g["name"] }
        all_channels = public_channels + private_channels
        all_channels.include? channelName ? return true : return false
    end

    def process()
        log("debug", "#{__method__.to_s} in  #{@thisFileName} is invoked.")
        begin
            @client = SlackChatter::Client.new(@accessToken)

            if isAccessTokenValid(@client) && isValidChannel(@channelID) then
                response = @client.chat.post_message(@channelID, message, :as_user => "true", :parse => "full")
            else
                log("info","Invalid client or channel.")
            end
        rescue
            log("error", __method__.to_s + " method failed in " + @thisFileName)
        end 
        log("debug", "#{__method__.to_s} in  #{@thisFileName} is completed.")       
    end 

    def message
        case
          when @message_type=="welcome"
            return "Hello #{@message_to}, \nWelcome to our channel '#{@channelID}' in slack. \nThanks, \nCloudmunch."
          when @message_type=="assignment"
            return "Hello #{@message_to}, \nYou have been assigned a new task.\n #{@message}\nHope you will complete soon. \nThanks, \nCloudmunch."
          when @message_type=="text" || @message_type.empty?
            return "Hello #{@message_to}, \n#{@message} \nThanks, \nCloudmunch."
        end 
    end

    def exitWithMessage(msgType, msg)
        if msg.nil? || msg.empty? then
            msg = "Action on cloudmunch data base returned empty! refer log for more details"
        end
        log(msgType, msg)
        log("info", msg)
        exit 1
    end

    def cleanupApp()
        log("info", __method__.to_s + " is invoked in " + @thisFileName)
        logClose() 
    end


end

cloudmunchSlackChatterApp = CloudmunchSlackChatterApp.new()
cloudmunchSlackChatterApp.start()
