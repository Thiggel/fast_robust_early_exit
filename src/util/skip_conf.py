import numpy as np
import torch
import torch.nn.functional as F
from transformers import AutoConfig


def recurrent_classifier(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    assert hidden_states is not None
    assert classifier is not None
    
    if layer_index == 1 or should_reset:
        classifier.reset()

    try:
        preds = classifier(hidden_states)
    except Exception as e:
        classifier.reset()
        preds = classifier(hidden_states)

    probs = torch.softmax(preds, dim=-1)
    return probs[..., 1].squeeze()


def last_three_hiddens_classifier(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    assert classifier is not None

    if all_hidden_states is None or len(all_hidden_states) < 3:
        return torch.zeros(hidden_states.shape[0])

    last_three_hiddens = torch.cat(all_hidden_states[-3:], dim=2)

    preds = classifier(last_three_hiddens)
    probs = torch.softmax(preds, dim=-1)
    return probs[..., 1].squeeze()

def hidden_state_saturation(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    if all_hidden_states is None or len(all_hidden_states) < 2:
        return torch.zeros(hidden_states.shape[0])

    last_hidden = all_hidden_states[-1]
    second_last_hidden = all_hidden_states[-2]

    similarity = torch.nn.functional.cosine_similarity(last_hidden, second_last_hidden, dim=2).squeeze()

    return similarity


def last_three_top_prob_heuristic(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    if (
        all_softmax_values is None 
        or len(all_softmax_values) < 3
        or layer_index < 3 # minimum exit is layer 4
    ):
        return torch.zeros(hidden_states.shape[0])
    max_length = max(sm.size(1) for sm in all_softmax_values[-3:])

    # Pad each softmax tensor in the last three to have the same sequence length
    padded_softmax_values = [
        F.pad(sm, (0, 0, 0, max_length - sm.size(1)), "constant", 0)
        if sm.size(1) < max_length else sm
        for sm in all_softmax_values[-3:]
    ]

    # Ensure all tensors have the same batch size and softmax dimension
    max_dim_0 = max(sm.size(0) for sm in padded_softmax_values)  # max batch size
    max_dim_2 = max(sm.size(2) for sm in padded_softmax_values)  # max softmax dimension

    # Final padding for batch size and softmax dimension
    fully_padded_softmax_values = [
        F.pad(sm, (0, max_dim_2 - sm.size(2), 0, max_length - sm.size(1), 0, max_dim_0 - sm.size(0)), "constant", 0)
        for sm in padded_softmax_values
    ]

    # Stack the padded softmax values
    softmax_stack = torch.stack(fully_padded_softmax_values, dim=1)

    # Compute the max probability across the softmax dimension
    top_probs = softmax_stack.max(dim=-1).values.squeeze(-1)

    # Check if the probabilities are increasing across the last three
    increasing = torch.all(top_probs[:, 1:] > top_probs[:, :-1], dim=1)

    # last confidence must be above 0.9
    above_threshold = top_probs[:, -1] > threshold

    confidence = increasing & above_threshold
    confidence = confidence.float()
    
    return confidence

def softmax_confidence(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    assert logits is not None
    probs = torch.softmax(logits, dim=-1)
    top_2 = torch.topk(probs, dim=-1, k=2)[0]

    conf = (top_2[..., 0] - top_2[..., 1]).squeeze()

    return conf


def meta_confidence(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
    threshold: float = None,
):
    assert hidden_states is not None
    assert classifier is not None
    
    preds = classifier(hidden_states)
    probs = torch.softmax(preds, dim=-1)
    return probs[..., 1].squeeze()


def get_confidence_class(key):

    _conf_class_map = {
        'softmax': softmax_confidence,
        'meta': meta_confidence,
        'recurrent_classifier': recurrent_classifier,
        'last_three_hiddens_classifier': last_three_hiddens_classifier,
        'last_three_top_prob_heuristic': last_three_top_prob_heuristic,
        'hidden_state_saturation': hidden_state_saturation,
    }

    if key in _conf_class_map:
        return _conf_class_map[key]
    else:
        raise ValueError('Invalid confidence measure: {}'.format(key))


def get_skip_mask(
    logits: torch.Tensor = None,
    hidden_states: torch.Tensor = None,
    classifier: torch.nn.Linear = None,
    config: AutoConfig = None,
    pos_time: int = 1,
    adapt_threshold: float = None,
    return_conf=False,
    all_hidden_states: list[torch.Tensor] = None,
    all_softmax_values: list[torch.Tensor] = None,
    layer_index: int = None,
    should_reset: bool = False,
):
    assert config.exit_conf_type is not None or config.shallow2deep_conf_type is not None

    if config.exit_conf_type is not None:
        key = config.exit_conf_type
        if config.exit_position_temp is not None:
            # decays the confidence threshold with decoding time stp.        
            correct_by_pos = lambda i: config.exit_conf_threshold * np.exp(
                - config.exit_position_temp * i / config.max_answer_length
            ) / 10 + 9 * config.exit_conf_threshold / 10
            threshold = correct_by_pos(pos_time)
        else:
            threshold = config.exit_conf_threshold
    elif config.shallow2deep_conf_type is not None:
        key = config.shallow2deep_conf_type
        threshold = config.shallow2deep_conf_threshold if adapt_threshold is None else adapt_threshold

    conf_measure = get_confidence_class(key=key)    
    conf = conf_measure(
        logits=logits, 
        hidden_states=hidden_states, 
        classifier=classifier,
        all_hidden_states=all_hidden_states,
        all_softmax_values=all_softmax_values,
        layer_index=layer_index,
        should_reset=should_reset,
        threshold=config.exit_conf_threshold,
    )
    mask = torch.where(conf <= threshold, 0., 1.).bool()
    if not return_conf:

        return mask  # Return the whole mask tensor
    else:
        return mask, conf
